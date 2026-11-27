import Foundation
import AppKit

struct WEProjectInfo: Identifiable, Hashable {
    var id: String { folder.path }
    let workshopID: String
    let folder: URL
    let title: String
    let type: String
    let preview: URL?
    let supported: Bool
}

/// Разбор проектов Wallpaper Engine (project.json).
enum WEProject {
    static func readJSON(_ folder: URL) -> [String: Any]? {
        guard let d = try? Data(contentsOf: folder.appendingPathComponent("project.json")) else { return nil }
        return (try? JSONSerialization.jsonObject(with: d)) as? [String: Any]
    }

    /// Пресет: настройки + свои файлы поверх другого проекта (dependency).
    static func presetBase(_ j: [String: Any], folder: URL) -> URL? {
        guard j["preset"] is [String: Any], let dep = j["dependency"] as? String else { return nil }
        let base = folder.deletingLastPathComponent().appendingPathComponent(dep, isDirectory: true)
        return FileManager.default.fileExists(atPath: base.appendingPathComponent("project.json").path) ? base : nil
    }

    static func info(folder: URL) -> WEProjectInfo? {
        guard let j = readJSON(folder) else { return nil }
        if let base = presetBase(j, folder: folder), let b = info(folder: base) {
            return WEProjectInfo(workshopID: folder.lastPathComponent, folder: folder,
                                 title: clean(j["title"] as? String ?? folder.lastPathComponent),
                                 type: b.type, preview: (j["preview"] as? String).map { folder.appendingPathComponent($0) },
                                 supported: b.supported && b.type != "scene")
        }
        let type = (j["type"] as? String ?? "").lowercased()
        let file = j["file"] as? String
        let supported = ((type == "video" || type == "web") && file != nil
            && FileManager.default.fileExists(atPath: folder.appendingPathComponent(file!).path))
            || (type == "scene" && WESceneConverter.canConvert(folder: folder))
        return WEProjectInfo(workshopID: folder.lastPathComponent, folder: folder,
                             title: clean(j["title"] as? String ?? folder.lastPathComponent),
                             type: type.isEmpty ? "?" : type,
                             preview: (j["preview"] as? String).map { folder.appendingPathComponent($0) },
                             supported: supported)
    }

    static func makeItem(folder: URL) throws -> WallpaperItem {
        guard let j = readJSON(folder), let info = info(folder: folder) else { throw LWError(tr("нет project.json")) }
        guard info.supported else {
            throw LWError(tr("тип «%@» не поддерживается", info.type))
        }
        let isWorkshop = folder.path.contains("/workshop/content/")

        // Пресет: берём основной проект и подставляем значения и файлы пресета
        if let base = presetBase(j, folder: folder), let bj = readJSON(base), let preset = j["preset"] as? [String: Any] {
            var item = try makeItem(folder: base)
            var lower: [String: Any] = [:]
            for (k, v) in preset { lower[k.lowercased()] = v }
            item.properties = item.properties.map { p in
                var p = p
                guard let v = lower[p.key.lowercased()] else { return p }
                if let str = v as? String, str.hasPrefix("files/") || FileManager.default.fileExists(atPath: folder.appendingPathComponent(str).path) && !str.isEmpty {
                    p.value = .string(folder.appendingPathComponent(str).absoluteString)
                } else if let b = v as? Bool, p.kind == .bool { p.value = .bool(b) }
                else if let n = v as? NSNumber { p.value = p.kind == .combo ? .string(n.stringValue) : .number(n.doubleValue) }
                else if let str = v as? String { p.value = .string(str) }
                return p
            }
            item.title = info.title
            item.workshopID = isWorkshop ? info.workshopID : nil
            if let pv = j["preview"] as? String { item.preview = folder.appendingPathComponent(pv).path }
            item.tags = ((j["tags"] as? [String]) ?? []) + ["preset"]
            _ = bj
            return item
        }

        // Сцена WE → конвертируем в сцену LiveWall (или GIF) в папке библиотеки
        if info.type == "scene" {
            let dest = Paths.library.appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: dest, withIntermediateDirectories: true)
            let out: WESceneConverter.Output
            do { out = try WESceneConverter.convert(folder: folder, into: dest) } catch {
                try? FileManager.default.removeItem(at: dest); throw error
            }
            var preview: String? = nil
            if let p = j["preview"] as? String, FileManager.default.fileExists(atPath: folder.appendingPathComponent(p).path) {
                let name = "we-preview." + (p as NSString).pathExtension
                try? FileManager.default.copyItem(at: folder.appendingPathComponent(p), to: dest.appendingPathComponent(name))
                preview = name
            }
            var tags = (j["tags"] as? [String]) ?? []
            tags.append("wallpaper engine")
            return WallpaperItem(id: UUID().uuidString, title: info.title, type: out.type, folder: dest.path,
                                 entry: out.entry, preview: preview, tags: tags, source: .steam,
                                 workshopID: isWorkshop ? info.workshopID : nil,
                                 properties: DefaultProps.forType(out.type))
        }

        let t: WallpaperType = info.type == "video" ? .video : .web
        var props = t == .video ? DefaultProps.forType(.video) : []
        props += properties(j)
        return WallpaperItem(id: UUID().uuidString, title: info.title, type: t, folder: folder.path,
                             entry: j["file"] as? String ?? "",
                             preview: (j["preview"] as? String),
                             tags: (j["tags"] as? [String]) ?? [],
                             source: .steam,
                             workshopID: isWorkshop ? info.workshopID : nil,
                             properties: props)
    }

    static let knownLabels: [String: String] = [
        "ui_browse_properties_scheme_color": tr("Цвет схемы"),
        "ui_browse_properties_alignment": tr("Выравнивание"),
        "ui_browse_properties_volume": tr("Громкость"),
        "ui_browse_properties_playback_rate": tr("Скорость"),
    ]

    static func clean(_ s: String) -> String {
        var r = s.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let k = knownLabels[r] { return k }
        if r.hasPrefix("ui_") {
            r = r.replacingOccurrences(of: "ui_browse_properties_", with: "").replacingOccurrences(of: "ui_", with: "")
            r = r.replacingOccurrences(of: "_", with: " ").capitalized
        }
        return r
    }

    private static func str(_ v: Any?) -> String {
        if let n = v as? NSNumber {
            let d = n.doubleValue
            return d == d.rounded() ? String(Int(d)) : String(d)
        }
        return v.map { "\($0)" } ?? ""
    }

    static func properties(_ j: [String: Any]) -> [WallpaperProperty] {
        guard let general = j["general"] as? [String: Any],
              let ps = general["properties"] as? [String: Any] else { return [] }
        var out: [WallpaperProperty] = []
        for (key, raw) in ps {
            guard let p = raw as? [String: Any], let type = p["type"] as? String else { continue }
            let label = clean(p["text"] as? String ?? key)
            let order = (p["order"] as? NSNumber)?.intValue ?? 100
            switch type.lowercased() {
            case "slider":
                let v = (p["value"] as? NSNumber)?.doubleValue ?? 0
                let lo = (p["min"] as? NSNumber)?.doubleValue ?? 0
                let hi = (p["max"] as? NSNumber)?.doubleValue ?? max(1, v)
                let step = (p["step"] as? NSNumber)?.doubleValue ?? ((p["precision"] as? NSNumber)?.intValue == 0 ? 1 : nil)
                out.append(WallpaperProperty(key: key, label: label, kind: .slider, value: .number(v), min: lo, max: hi, step: step, order: order))
            case "color":
                out.append(WallpaperProperty(key: key, label: label, kind: .color, value: .string(p["value"] as? String ?? "1 1 1"), order: order))
            case "bool":
                out.append(WallpaperProperty(key: key, label: label, kind: .bool, value: .bool((p["value"] as? NSNumber)?.boolValue ?? false), order: order))
            case "combo":
                let opts = (p["options"] as? [[String: Any]] ?? []).map {
                    PropertyOption(label: clean($0["label"] as? String ?? str($0["value"])), value: str($0["value"]))
                }
                out.append(WallpaperProperty(key: key, label: label, kind: .combo, value: .string(str(p["value"])), options: opts, order: order))
            case "file", "directory":
                out.append(WallpaperProperty(key: key, label: label, kind: .text, value: .string(p["value"] as? String ?? ""), order: order))
            case "textinput":
                out.append(WallpaperProperty(key: key, label: label, kind: .text, value: .string(p["value"] as? String ?? ""), order: order))
            default:
                continue
            }
        }
        return out.sorted { $0.order < $1.order }
    }
}

/// Импорт из папки мастерской Steam и загрузка через steamcmd.
@MainActor
final class SteamService: ObservableObject {
    static let appID = "431960" // Wallpaper Engine

    @Published var projects: [WEProjectInfo] = []
    @Published var log = ""
    @Published var busy = false
    @Published var status = ""

    weak var app: AppState?

    private var home: URL { FileManager.default.homeDirectoryForCurrentUser }

    func steamcmdPath() -> String? {
        let fm = FileManager.default
        if let c = app?.settings.steamcmdPath, !c.isEmpty {
            let p = (c as NSString).expandingTildeInPath
            if fm.isExecutableFile(atPath: p) { return p }
        }
        let cands = [SteamAccount.bundledSteamCMD.path, "/opt/homebrew/bin/steamcmd", "/usr/local/bin/steamcmd",
                     home.appendingPathComponent("Steam/steamcmd.sh").path,
                     home.appendingPathComponent("steamcmd/steamcmd.sh").path,
                     home.appendingPathComponent("Library/Application Support/Steam/steamcmd.sh").path]
        return cands.first { fm.isExecutableFile(atPath: $0) }
    }

    var candidateDirs: [URL] {
        let sub = "steamapps/workshop/content/\(Self.appID)"
        var list: [URL] = []
        if let c = app?.settings.steamWorkshopPath, !c.isEmpty { list.append(URL(fileURLWithPath: (c as NSString).expandingTildeInPath)) }
        list += [home.appendingPathComponent("Library/Application Support/Steam/\(sub)"),
                 home.appendingPathComponent("Steam/\(sub)"),
                 home.appendingPathComponent("steamcmd/\(sub)")]
        if let cmd = steamcmdPath() {
            let resolved = URL(fileURLWithPath: cmd).resolvingSymlinksInPath().deletingLastPathComponent()
            list.append(resolved.appendingPathComponent(sub))
        }
        var seen = Set<String>()
        return list.filter { seen.insert($0.standardizedFileURL.path).inserted }
    }

    var existingDirs: [URL] { candidateDirs.filter { FileManager.default.isDirectory($0) } }

    func scan() {
        var out: [WEProjectInfo] = []
        for dir in existingDirs {
            let subs = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
            for s in subs where FileManager.default.isDirectory(s) {
                if let i = WEProject.info(folder: s) { out.append(i) }
            }
        }
        projects = out.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        status = existingDirs.isEmpty
            ? tr("Папка мастерской Wallpaper Engine не найдена. Укажите её вручную или скачайте предмет через steamcmd.")
            : tr("Найдено проектов: %@, поддерживается: %@", out.count, out.filter(\.supported).count)
    }

    func existing(_ p: WEProjectInfo) -> WallpaperItem? {
        app?.library.items.first {
            $0.folderURL.standardizedFileURL.path == p.folder.standardizedFileURL.path
                || ($0.source == .steam && $0.workshopID != nil && $0.workshopID == p.workshopID)
        }
    }

    func isImported(_ p: WEProjectInfo) -> Bool { existing(p) != nil }

    @discardableResult
    func importProject(_ p: WEProjectInfo) -> WallpaperItem? {
        guard let lib = app?.library, !isImported(p) else { return nil }
        do {
            let item = try WEProject.makeItem(folder: p.folder)
            lib.add(item)
            lib.generatePreview(for: item)
            objectWillChange.send()
            return item
        } catch {
            status = "\(p.title): \(error.localizedDescription)"
            return nil
        }
    }

    func importAllSupported() {
        var n = 0
        for p in projects where p.supported && !isImported(p) { if importProject(p) != nil { n += 1 } }
        status = tr("Импортировано: %@", n)
    }

    /// Импортирует все поддерживаемые проекты, собирает из них плейлист «Wallpaper Engine» и включает его.
    @discardableResult
    func importAllAsPlaylist(activate: Bool = true, skipHidden: Bool = false) -> Int {
        scan()
        guard let app else { return 0 }
        var ids: [String] = []
        if !skipHidden { app.settings.hiddenWorkshopIDs = [] }   // явный «импортировать всё» возвращает скрытые
        for p in projects where p.supported {
            if skipHidden && app.settings.hiddenWorkshopIDs.contains(p.workshopID) { continue }
            if let it = importProject(p) { ids.append(it.id) }
            else if let ex = existing(p) { ids.append(ex.id) }
        }
        guard !ids.isEmpty else { status = tr("Нет поддерживаемых обоев для импорта"); return 0 }
        let name = "Wallpaper Engine"
        if let i = app.playlists.firstIndex(where: { $0.name == name }) {
            app.playlists[i].items = ids
        } else {
            app.playlists.append(Playlist(name: name, items: ids, intervalMinutes: 30))
        }
        if activate, let pl = app.playlists.first(where: { $0.name == name }) { app.activatePlaylist(pl.id) }
        status = tr("Импортировано и добавлено в плейлист: %@", ids.count)
        app.showToast(status)
        return ids.count
    }

    static func parseID(_ s: String) -> String? {
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines)
        if let r = t.range(of: #"id=(\d+)"#, options: .regularExpression) {
            return String(t[r].dropFirst(3))
        }
        if let r = t.range(of: #"\d{6,}"#, options: .regularExpression) { return String(t[r]) }
        return nil
    }

    func download(_ input: String) {
        guard !busy else { return }
        guard let id = Self.parseID(input) else { status = tr("Не удалось распознать ID предмета"); return }
        guard let cmd = steamcmdPath() else { status = tr("steamcmd не найден. Установите его (см. инструкцию ниже) или укажите путь."); return }
        guard !SteamAccount.rosettaMissing else { status = SteamAccount.rosettaMessage; return }
        let user = app?.settings.steamUser.trimmingCharacters(in: .whitespaces) ?? ""
        guard !user.isEmpty else { status = tr("Укажите логин Steam"); return }

        busy = true
        status = tr("Загрузка предмета %@…", id)
        log += "\n> steamcmd +login \(user) +workshop_download_item \(Self.appID) \(id) +quit\n"

        let p = Process()
        p.executableURL = URL(fileURLWithPath: cmd)
        p.arguments = ["+login", user, "+workshop_download_item", Self.appID, id, "+quit"]
        p.standardInput = FileHandle.nullDevice
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe
        let reader = pipe.fileHandleForReading
        reader.readabilityHandler = { h in
            let d = h.availableData
            guard !d.isEmpty, let s = String(data: d, encoding: .utf8) else { return }
            Task { @MainActor [weak self] in self?.appendLog(s) }
        }
        p.terminationHandler = { proc in
            reader.readabilityHandler = nil
            let rest = reader.readDataToEndOfFile()
            let s = String(data: rest, encoding: .utf8) ?? ""
            let code = proc.terminationStatus
            Task { @MainActor [weak self] in
                self?.appendLog(s)
                self?.finishDownload(id: id, code: code)
            }
        }
        do { try p.run() } catch {
            busy = false
            status = tr("Не удалось запустить steamcmd: %@", error.localizedDescription)
        }
    }

    private func appendLog(_ s: String) {
        log += s
        if log.count > 40000 { log = String(log.suffix(30000)) }
    }

    private func finishDownload(id: String, code: Int32) {
        busy = false
        var folder: URL?
        if let r = log.range(of: "Downloaded item \(id) to \"([^\"]+)\"", options: [.regularExpression, .backwards]) {
            let m = String(log[r])
            if let q1 = m.firstIndex(of: "\""), let q2 = m.lastIndex(of: "\""), q1 < q2 {
                folder = URL(fileURLWithPath: String(m[m.index(after: q1)..<q2]))
            }
        }
        if folder == nil {
            folder = candidateDirs.map { $0.appendingPathComponent(id) }.first { FileManager.default.isDirectory($0) }
        }
        guard let folder, let info = WEProject.info(folder: folder) else {
            status = tr("Не удалось скачать (код %@). Если steamcmd просит пароль — нажмите «Войти в steamcmd» и войдите один раз в Терминале.", code)
            return
        }
        scan()
        if !info.supported {
            status = tr("Скачано «%@», но тип «%@» не поддерживается.", info.title, info.type)
        } else if importProject(info) != nil {
            status = tr("Скачано и добавлено в библиотеку: «%@»", info.title)
        } else if isImported(info) {
            status = tr("«%@» уже в библиотеке", info.title)
        }
    }

    /// Открывает Терминал, где пользователь сам вводит пароль и код Steam Guard (данные кешируются steamcmd).
    func openLoginTerminal() {
        guard let cmd = steamcmdPath() else { status = tr("steamcmd не найден"); return }
        let user = app?.settings.steamUser ?? ""
        let script = """
        #!/bin/bash
        echo "Вход в Steam для LiveWall. Введите пароль и код Steam Guard — steamcmd запомнит вход."
        '\(cmd)' +login '\(user.replacingOccurrences(of: "'", with: ""))' +quit
        echo
        echo "Готово. Это окно можно закрыть."
        """
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("livewall-steam-login.command")
        do {
            try script.write(to: url, atomically: true, encoding: .utf8)
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: url.path)
            NSWorkspace.shared.open(url)
        } catch {
            status = tr("Не удалось открыть Терминал: %@", error.localizedDescription)
        }
    }
}
