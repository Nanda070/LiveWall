import Foundation
import AppKit
import WebKit
import Darwin

/// Вход в Steam и синхронизация мастерской Wallpaper Engine без терминала.
/// Под капотом — официальная утилита Valve steamcmd в невидимом псевдотерминале.
/// Пароль передаётся только в steamcmd и нигде не сохраняется; steamcmd сам кэширует вход.
@MainActor
final class SteamAccount: ObservableObject {
    enum Session: Equatable { case unknown, checking, signedOut, signedIn(String) }
    enum Login: Equatable { case idle, connecting, needsCode(String), waitingMobile, success, failed(String) }
    enum Sync: Equatable {
        case idle, installing, fetching, downloading(done: Int, total: Int), importing, done(new: Int), failed(String)
    }

    @Published private(set) var session: Session = .unknown
    @Published private(set) var login: Login = .idle
    @Published private(set) var sync: Sync = .idle
    @Published var showLogin = false
    @Published var showWebLogin = false
    @Published private(set) var lastLog = ""

    weak var app: AppState?
    var steam: SteamService? { app?.steam }

    static let bundledDir = Paths.root.appendingPathComponent("steamcmd", isDirectory: true)
    static var bundledSteamCMD: URL { bundledDir.appendingPathComponent("steamcmd.sh") }

    /// steamcmd для macOS собран только под Intel: на Apple Silicon без Rosetta 2 он не запускается (код 126).
    static var rosettaMissing: Bool {
        #if arch(arm64)
        return !FileManager.default.fileExists(atPath: "/Library/Apple/usr/libexec/oah/libRosettaRuntime")
        #else
        return false
        #endif
    }
    static var rosettaMessage: String {
        tr("steamcmd нужна Rosetta 2. Выполните в Терминале: softwareupdate --install-rosetta --agree-to-license")
    }

    var installed: Bool { steam?.steamcmdPath() != nil }
    var username: String { app?.settings.steamUser ?? "" }

    // MARK: Псевдотерминал

    /// Процесс steamcmd с PTY: steamcmd спрашивает пароль и коды так же, как в Терминале.
    final class PTYProcess: @unchecked Sendable {
        let process = Process()
        private var master: Int32 = -1
        private var slave: Int32 = -1
        private var masterHandle: FileHandle?
        var onOutput: ((String) -> Void)?
        var onExit: ((Int32) -> Void)?

        init(exe: String, args: [String]) throws {
            guard openpty(&master, &slave, nil, nil, nil) == 0 else { throw LWError("openpty") }
            process.executableURL = URL(fileURLWithPath: exe)
            process.arguments = args
            let sh = FileHandle(fileDescriptor: slave, closeOnDealloc: true)
            process.standardInput = sh; process.standardOutput = sh; process.standardError = sh
            masterHandle = FileHandle(fileDescriptor: master, closeOnDealloc: true)
        }

        func run() throws {
            masterHandle?.readabilityHandler = { [weak self] h in
                let d = h.availableData
                guard !d.isEmpty else { return }
                let s = String(decoding: d, as: UTF8.self)
                DispatchQueue.main.async { self?.onOutput?(s) }
            }
            process.terminationHandler = { [weak self] p in
                let code = p.terminationStatus
                DispatchQueue.main.async {
                    self?.masterHandle?.readabilityHandler = nil
                    self?.onExit?(code)
                }
            }
            try process.run()
        }

        func send(_ line: String) {
            masterHandle?.write((line + "\n").data(using: .utf8)!)
        }

        func terminate() { if process.isRunning { process.terminate() } }
    }

    private var loginProc: PTYProcess?
    private var buffer = ""
    private var passwordSent = false
    private var pendingPassword: String?

    // MARK: Сессия

    /// Проверяет, есть ли закэшированный вход (без пароля).
    func checkSession() {
        guard let exe = steam?.steamcmdPath() else { session = .signedOut; return }
        let user = username.trimmingCharacters(in: .whitespaces)
        guard !user.isEmpty else { session = .signedOut; return }
        session = .checking
        guard let p = try? PTYProcess(exe: exe, args: ["+login", user, "+quit"]) else { session = .signedOut; return }
        var out = ""
        var decided = false
        p.onOutput = { [weak self, weak p] s in
            out += s
            let low = out.lowercased()
            if !decided && (low.contains("password:") || low.contains("cached credentials not found") || low.contains("two-factor") || low.contains("steam guard")) {
                decided = true; p?.terminate(); self?.session = .signedOut
            } else if !decided && (low.contains("waiting for user info...ok") || low.contains("logged in ok")) {
                decided = true; self?.session = .signedIn(user)
            }
        }
        p.onExit = { [weak self] _ in
            if !decided { self?.session = .signedOut }
            self?.checkProc = nil
        }
        checkProc = p
        do { try p.run() } catch { session = .signedOut }
    }
    private var checkProc: PTYProcess?

    // MARK: Вход

    func signIn(user: String, password: String) {
        let u = user.trimmingCharacters(in: .whitespaces)
        guard !u.isEmpty, let exe = steam?.steamcmdPath() else {
            login = .failed(tr("Сначала установите steamcmd")); return
        }
        guard !Self.rosettaMissing else { login = .failed(Self.rosettaMessage); return }
        app?.settings.steamUser = u
        loginProc?.terminate()
        buffer = ""; passwordSent = false; pendingPassword = password
        login = .connecting
        do {
            let p = try PTYProcess(exe: exe, args: ["+login", u, "+quit"])
            p.onOutput = { [weak self] s in self?.handleLoginOutput(s) }
            p.onExit = { [weak self] code in self?.loginExited(code) }
            loginProc = p
            try p.run()
        } catch {
            login = .failed(error.localizedDescription)
        }
    }

    func submitCode(_ code: String) {
        loginProc?.send(code.trimmingCharacters(in: .whitespaces))
        login = .connecting
    }

    func cancelLogin() {
        loginProc?.terminate(); loginProc = nil
        pendingPassword = nil
        login = .idle
    }

    private func handleLoginOutput(_ s: String) {
        buffer += s
        lastLog = String(buffer.suffix(600))
        let low = buffer.lowercased()
        let tail = String(low.suffix(300))
        if !passwordSent && tail.contains("password:") {
            passwordSent = true
            if let p = pendingPassword { loginProc?.send(p) }
            pendingPassword = nil
            return
        }
        if tail.hasSuffix("code:") || tail.contains("two-factor code:") || tail.contains("steam guard code:") || tail.contains("auth code") {
            let isEmail = tail.contains("email") || tail.contains("mail")
            login = .needsCode(isEmail ? tr("Код из письма Steam") : tr("Код Steam Guard из приложения"))
            buffer = ""
            return
        }
        if tail.contains("steam mobile app") && tail.contains("confirm") {
            login = .waitingMobile
        }
        if tail.contains("waiting for user info...ok") || tail.contains("logged in ok") {
            login = .success
            session = .signedIn(username)
        }
        // Ошибки steamcmd: «FAILED (Invalid Password)», «ERROR (Invalid Password)», «ERROR! …» — только последняя строка вывода
        let lines = buffer.components(separatedBy: CharacterSet.newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if let line = lines.last(where: { $0.contains("FAILED (") || $0.contains("ERROR (") || $0.contains("ERROR!") }), login != .success {
            let l = line.lowercased()
            if l.contains("invalid password") { login = .failed(tr("Неверный логин или пароль")) }
            else if l.contains("rate limit") { login = .failed(tr("Слишком много попыток. Подождите немного.")) }
            else if !l.contains("timeout") { login = .failed(line.trimmingCharacters(in: .whitespaces)) }
        }
    }

    private func loginExited(_ code: Int32) {
        loginProc = nil
        pendingPassword = nil
        if login == .success {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                MainActor.assumeIsolated { self?.showLogin = false; self?.login = .idle }
            }
        } else if case .failed = login {
        } else if code == 126 && Self.rosettaMissing {
            login = .failed(Self.rosettaMessage)
        } else {
            login = .failed(tr("Вход не выполнен (код %@)", code))
        }
    }

    func signOut() {
        // Сбрасываем вход только у steamcmd, который установил сам LiveWall.
        // Общие файлы Steam (~/Library/Application Support/Steam) не трогаем — иначе вылетит и обычный клиент Steam.
        let own = Self.bundledDir.appendingPathComponent("config")
        for f in ["config.vdf", "loginusers.vdf"] { try? FileManager.default.removeItem(at: own.appendingPathComponent(f)) }
        app?.settings.steamUser = ""
        let store = WKWebsiteDataStore.default()
        store.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            let steamRecords = records.filter { $0.displayName.contains("steam") }
            store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: steamRecords) {}
        }
        session = .signedOut
    }

    // MARK: Установка steamcmd

    func installSteamCMD() {
        guard sync != .installing else { return }
        guard !Self.rosettaMissing else { sync = .failed(Self.rosettaMessage); return }
        sync = .installing
        Task {
            do {
                let url = URL(string: "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_osx.tar.gz")!
                let (tmp, resp) = try await URLSession.shared.download(from: url)
                guard (resp as? HTTPURLResponse)?.statusCode == 200 else { throw LWError(tr("Не удалось скачать steamcmd")) }
                try FileManager.default.createDirectory(at: Self.bundledDir, withIntermediateDirectories: true)
                try Shell.run("/usr/bin/tar", ["-xzf", tmp.path, "-C", Self.bundledDir.path])
                // Первый запуск докачивает файлы steamcmd
                let exe = Self.bundledSteamCMD.path
                _ = try await Task.detached { try Shell.run(exe, ["+quit"]) }.value
                sync = .idle
                objectWillChange.send()
                app?.showToast(tr("steamcmd установлен"))
            } catch {
                // повторный запуск после самообновления обычно проходит
                if FileManager.default.isExecutableFile(atPath: Self.bundledSteamCMD.path) {
                    let exe = Self.bundledSteamCMD.path
                    _ = try? await Task.detached { try Shell.run(exe, ["+quit"]) }.value
                    sync = .idle
                } else {
                    sync = .failed(error.localizedDescription)
                }
            }
        }
    }

    // MARK: Подписки (steamcommunity.com во встроенном WebView)

    let web = SteamWeb()

    // MARK: Синхронизация

    func startSync() {
        switch sync { case .fetching, .downloading, .importing, .installing: return; default: break }
        guard installed else { installSteamCMD(); return }
        guard case .signedIn = session else { showLogin = true; return }
        sync = .fetching
        Task {
            do {
                let ids = try await web.fetchSubscriptions()
                await downloadAndImport(ids)
            } catch SteamWeb.WebError.needsLogin {
                sync = .idle
                showWebLogin = true
            } catch {
                sync = .failed(error.localizedDescription)
            }
        }
    }

    private func downloadAndImport(_ ids: [String]) async {
        guard let steam, let app, let exe = steam.steamcmdPath() else { return }
        let have = Set(app.library.items.compactMap { $0.workshopID })
        // уже скачанные, но не импортированные — тоже подхватим
        let onDisk = Set(steam.existingDirs.flatMap { (try? FileManager.default.contentsOfDirectory(atPath: $0.path)) ?? [] })
        let hidden = Set(app.settings.hiddenWorkshopIDs)
        let missing = ids.filter { !have.contains($0) && !onDisk.contains($0) && !hidden.contains($0) }
        let before = app.library.items.count
        if !missing.isEmpty {
            var done = 0
            sync = .downloading(done: 0, total: missing.count)
            for chunk in stride(from: 0, to: missing.count, by: 4).map({ Array(missing[$0 ..< min($0 + 4, missing.count)]) }) {
                for attempt in 0..<2 {
                    let left = chunk.filter { id in !steam.existingDirs.contains { FileManager.default.fileExists(atPath: $0.appendingPathComponent(id).path) } }
                    if left.isEmpty { break }
                    var args = ["+login", username]
                    for id in left { args += ["+workshop_download_item", SteamService.appID, id] }
                    args.append("+quit")
                    let out = (try? await Task.detached { try Shell.run(exe, args) }.value) ?? ""
                    lastLog = String(out.suffix(600))
                    if attempt == 1 || !out.contains("Not logged on") { break }
                }
                done += chunk.count
                sync = .downloading(done: min(done, missing.count), total: missing.count)
            }
        }
        sync = .importing
        await Task.yield()
        steam.importAllAsPlaylist(activate: false, skipHidden: true)
        let added = app.library.items.count - before
        sync = .done(new: max(0, added))
        app.showToast(added > 0 ? tr("Добавлено из мастерской: %@", added) : tr("Новых подписок нет"))
    }
}

/// Невидимый браузер для steamcommunity.com: хранит вход (cookies) и читает список подписок.
@MainActor
final class SteamWeb: NSObject, WKNavigationDelegate {
    enum WebError: Error { case needsLogin, failed(String) }

    let webView: WKWebView
    private var loadCont: CheckedContinuation<Void, Error>?

    static let subscriptionsURL = "https://steamcommunity.com/my/myworkshopfiles/?appid=431960&browsefilter=mysubscriptions&numperpage=30"
    static let loginURL = URL(string: "https://steamcommunity.com/login/home/?goto=" +
        "%2Fmy%2Fmyworkshopfiles%2F%3Fappid%3D431960%26browsefilter%3Dmysubscriptions")!

    override init() {
        let cfg = WKWebViewConfiguration()
        cfg.websiteDataStore = .default()
        webView = WKWebView(frame: NSRect(x: 0, y: 0, width: 900, height: 700), configuration: cfg)
        super.init()
        webView.navigationDelegate = self
    }

    private var loadToken = 0

    private func load(_ url: URL) async throws {
        try await withCheckedThrowingContinuation { (c: CheckedContinuation<Void, Error>) in
            loadCont?.resume(throwing: WebError.failed("cancelled"))
            loadCont = c
            loadToken += 1
            let token = loadToken
            webView.load(URLRequest(url: url))
            // Страница так и не догрузилась — не висим вечно
            DispatchQueue.main.asyncAfter(deadline: .now() + 45) { [weak self] in
                MainActor.assumeIsolated {
                    guard let self, self.loadToken == token, let c = self.loadCont else { return }
                    self.loadCont = nil
                    c.resume(throwing: WebError.failed(tr("Steam не ответил вовремя. Попробуйте ещё раз.")))
                }
            }
        }
    }

    /// Steam по дороге перенаправляет страницу (/my → /id/…, проверка входа скриптом), и WebKit
    /// сообщает о прерванной загрузке (-999, «Frame load interrupted»). Это не ошибка: ждём следующую загрузку.
    private static func isInterruption(_ error: Error) -> Bool {
        let e = error as NSError
        return (e.domain == NSURLErrorDomain && e.code == NSURLErrorCancelled)
            || (e.domain == "WebKitErrorDomain" && e.code == 102)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadCont?.resume(); loadCont = nil
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if Self.isInterruption(error) { return }
        loadCont?.resume(throwing: error); loadCont = nil
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if Self.isInterruption(error) { return }
        loadCont?.resume(throwing: error); loadCont = nil
    }

    var isOnSubscriptions: Bool { webView.url?.absoluteString.contains("myworkshopfiles") ?? false }

    func fetchSubscriptions() async throws -> [String] {
        var all: [String] = []
        for page in 1...30 {
            try await load(URL(string: Self.subscriptionsURL + "&p=\(page)")!)
            if webView.url?.absoluteString.contains("/login") == true { throw WebError.needsLogin }
            let js = """
            (function(){var ids=[];document.querySelectorAll('a[href*="filedetails/?id="]').forEach(function(a){var m=a.href.match(/id=(\\d+)/);if(m&&ids.indexOf(m[1])<0)ids.push(m[1]);});
            var pi=(document.querySelector('.workshopBrowsePagingInfo')||{}).innerText||'';return JSON.stringify({ids:ids,paging:pi});})()
            """
            let r = try await webView.evaluateJavaScript(js) as? String ?? "{}"
            guard let d = r.data(using: .utf8), let j = try JSONSerialization.jsonObject(with: d) as? [String: Any] else { break }
            let ids = j["ids"] as? [String] ?? []
            let new = ids.filter { !all.contains($0) }
            if new.isEmpty { break }
            all += new
            // «1–30 из 47» → есть ли следующая страница
            let nums = (j["paging"] as? String ?? "").components(separatedBy: CharacterSet.decimalDigits.inverted).compactMap { Int($0) }
            if nums.count >= 3, nums[1] >= nums[2] { break }
            if ids.count < 30 { break }
        }
        return all
    }
}
