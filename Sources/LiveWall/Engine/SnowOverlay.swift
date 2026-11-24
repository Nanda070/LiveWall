import AppKit
import QuartzCore

// MARK: - Настройки снега для рендера

struct SnowConfig: Equatable {
    var density = 0.5        // 0.1…1
    var size = 1.0           // 0.5…2
    var onWindows = true     // оседает на верхних краях окон
    var cursor = true        // курсор отталкивает и сметает снег
    var garlands = false     // гирлянды под строкой меню
    var lowPower = false     // экономный режим (меньше частиц и кадров)
}

// MARK: - Окна, на которых может лежать снег

struct SnowWindow {
    let id: Int
    let rect: CGRect         // в координатах экрана, начало сверху слева
}

enum SnowWindowScan {
    /// Обычные окна приложений (слой 0), спереди назад. Разрешения macOS не нужны: берутся только рамки.
    static func windows(on screenCG: CGRect) -> [SnowWindow] {
        guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else { return [] }
        var out: [SnowWindow] = []
        for info in list {
            let layer = (info[kCGWindowLayer as String] as? NSNumber)?.intValue ?? 0
            guard layer == 0 else { continue }
            let alpha = (info[kCGWindowAlpha as String] as? NSNumber)?.doubleValue ?? 1
            let owner = info[kCGWindowOwnerName as String] as? String ?? ""
            guard alpha > 0.5, owner != "Dock", owner != "Window Server",
                  let bd = info[kCGWindowBounds as String] as? NSDictionary,
                  let r = CGRect(dictionaryRepresentation: bd),
                  r.width >= 160, r.height >= 80,
                  r.intersects(screenCG),
                  let num = (info[kCGWindowNumber as String] as? NSNumber)?.intValue else { continue }
            out.append(SnowWindow(id: num, rect: r.offsetBy(dx: -screenCG.minX, dy: -screenCG.minY)))
        }
        return out
    }
}

// MARK: - Холст со снегом

/// Прозрачный слой на весь экран: снежинки, сугробы на окнах, гирлянды.
/// Все координаты — в точках, начало сверху слева (view перевёрнут).
@MainActor
final class SnowCanvas: NSView {
    private struct Flake {
        var x: CGFloat, y: CGFloat
        var vx: CGFloat, vy: CGFloat
        var fall: CGFloat          // обычная скорость падения
        var r: CGFloat
        var phase: CGFloat
        var depth: CGFloat = 0.5   // 0 — далеко (мелкая, тусклая, медленная), 1 — близко (крупная, яркая)
        var flutter: CGFloat = 1   // частота покачивания
        var amp: CGFloat = 12      // размах покачивания
        var angle: CGFloat = 0     // поворот кристалла
        var spin: CGFloat = 0
        var life: CGFloat = .infinity   // у разлетевшихся от курсора — время жизни
    }

    private struct Surface {
        let id: Int
        let x0: CGFloat, x1: CGFloat   // видимый участок верхнего края
        let y: CGFloat
        let winX: CGFloat              // левый край окна (для индекса столбца)
        var landable = true            // false у сугроба закрытого окна: он только осыпается
    }

    /// Сугроб на верхнем краю окна. Когда окно двигают, снег съезжает в угол и сбрасывается с него.
    private struct Pile {
        var h: [CGFloat]
        var rect: CGRect
        var shed: Shed? = nil
        var ghost = false              // окно закрыто или свёрнуто: сугроб досыпается на старом месте
        var mass: CGFloat { h.reduce(0, +) }
    }

    private struct Shed {
        var dir: CGFloat               // −1 — сползает к левому углу, +1 — к правому
        var emit: CGFloat = 0          // таймер до следующего комка
        var t: CGFloat = 0             // сколько уже осыпается
    }

    private static let colW: CGFloat = 4
    private static let maxPile: CGFloat = 12

    var config = SnowConfig() { didSet { if config != oldValue { configChanged() } } }
    var menuBarHeight: CGFloat = 0
    var screenOrigin = CGPoint.zero    // Cocoa-координаты левого нижнего угла экрана
    var screenHeight: CGFloat = 0

    private var flakes: [Flake] = []
    private var surfaces: [Surface] = []
    private var piles: [Int: Pile] = [:]
    private var movingUntil: CFTimeInterval = 0
    private var link: CADisplayLink?
    private var time: CGFloat = 0
    private var cursor: CGPoint?

    /// Пока окна двигаются, контроллер опрашивает их чаще, чтобы сугроб не отставал.
    var windowsAreMoving: Bool { CACurrentMediaTime() < movingUntil || piles.values.contains { $0.shed != nil } }

    override var isFlipped: Bool { true }
    override var isOpaque: Bool { false }
    override func hitTest(_ point: NSPoint) -> NSView? { nil }

    // MARK: Жизненный цикл

    func startLoop() {
        guard link == nil else { link?.isPaused = false; return }
        let l = displayLink(target: self, selector: #selector(tick(_:)))
        l.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: config.lowPower ? 20 : 30)
        l.add(to: .main, forMode: .common)
        link = l
    }

    func pauseLoop() { link?.isPaused = true }

    func stopLoop() { link?.invalidate(); link = nil }

    private func configChanged() {
        link?.preferredFrameRateRange = CAFrameRateRange(minimum: 15, maximum: 30, preferred: config.lowPower ? 20 : 30)
        if !config.onWindows { piles.removeAll(); surfaces.removeAll() }
        needsDisplay = true
    }

    // MARK: Окна

    /// Вызывается несколько раз в секунду с актуальным списком окон (спереди назад).
    func updateWindows(_ wins: [SnowWindow]) {
        guard config.onWindows else { surfaces = []; return }
        var segs: [Surface] = []
        var alive = Set<Int>()
        for (i, w) in wins.enumerated() {
            let y = w.rect.minY
            guard y > menuBarHeight - 2, y < bounds.height - 40 else { continue }
            alive.insert(w.id)
            // Участки верхнего края, не закрытые окнами спереди
            var spans: [(CGFloat, CGFloat)] = [(w.rect.minX + 10, w.rect.maxX - 10)]
            for f in wins[..<i] where f.rect.minY < y + 1 && f.rect.maxY > y + 1 {
                spans = spans.flatMap { s -> [(CGFloat, CGFloat)] in
                    if f.rect.maxX <= s.0 || f.rect.minX >= s.1 { return [s] }
                    var r: [(CGFloat, CGFloat)] = []
                    if f.rect.minX > s.0 { r.append((s.0, f.rect.minX)) }
                    if f.rect.maxX < s.1 { r.append((f.rect.maxX, s.1)) }
                    return r
                }
            }
            for s in spans where s.1 - s.0 > 8 { segs.append(Surface(id: w.id, x0: s.0, x1: s.1, y: y, winX: w.rect.minX)) }

            let n = max(1, Int(w.rect.width / Self.colW))
            var p = piles[w.id] ?? Pile(h: [CGFloat](repeating: 0, count: n), rect: w.rect)
            if p.ghost { p.ghost = false; p.shed = nil }    // окно вернулось — сугроб снова его
            let dx = w.rect.minX - p.rect.minX, dy = w.rect.minY - p.rect.minY, dw = w.rect.width - p.rect.width
            if abs(dx) > 1.5 || abs(dy) > 1.5 || abs(dw) > 1.5 {
                movingUntil = CACurrentMediaTime() + 0.5
                if p.shed == nil, p.mass > 0.6 {
                    // Снег по инерции съезжает назад по ходу движения; при ресайзе — в ближний к основной массе угол
                    var dir: CGFloat = dx > 1.5 ? -1 : (dx < -1.5 ? 1 : 0)
                    if dir == 0 { dir = massCenter(p.h) < 0.5 ? -1 : 1 }
                    p.shed = Shed(dir: dir)
                }
            }
            if p.h.count != n { p.h = (0..<n).map { $0 < p.h.count ? p.h[$0] : 0 } }
            p.rect = w.rect
            piles[w.id] = p
        }
        // Окно закрыто, свёрнуто или ушло на другой Space: сугроб остаётся на месте и осыпается с угла
        for (id, var p) in piles where !alive.contains(id) {
            if p.mass < 0.4 { piles[id] = nil; continue }
            if !p.ghost {
                p.ghost = true
                p.shed = Shed(dir: massCenter(p.h) < 0.5 ? -1 : 1)
                piles[id] = p
            }
            segs.append(Surface(id: id, x0: p.rect.minX + 10, x1: p.rect.maxX - 10, y: p.rect.minY, winX: p.rect.minX, landable: false))
        }
        surfaces = segs
    }

    private func massCenter(_ h: [CGFloat]) -> CGFloat {
        let m = h.reduce(0, +)
        guard m > 0, h.count > 1 else { return 0.5 }
        var acc: CGFloat = 0
        for (i, v) in h.enumerated() { acc += v * CGFloat(i) }
        return acc / m / CGFloat(h.count - 1)
    }

    func clearSettledSnow() {
        for k in Array(piles.keys) {
            guard var p = piles[k] else { continue }
            p.h = [CGFloat](repeating: 0, count: p.h.count); p.shed = nil
            piles[k] = p
        }
    }

    // MARK: Симуляция

    @objc private func tick(_ link: CADisplayLink) {
        let dt = CGFloat(min(0.1, max(0.001, link.targetTimestamp - link.timestamp)))
        step(dt)
        needsDisplay = true
    }

    private var targetCount: Int {
        let area = bounds.width * bounds.height / (1440 * 900)
        let k = config.lowPower ? 0.5 : 1.0
        return Int(CGFloat(config.density * k) * 520 * max(0.5, area))
    }

    private func spawn(anywhere: Bool) -> Flake {
        // Три слоя глубины: больше мелких далёких снежинок, меньше крупных близких
        let u = CGFloat.random(in: 0...1)
        let depth = u < 0.5 ? CGFloat.random(in: 0...0.33) : (u < 0.85 ? CGFloat.random(in: 0.33...0.7) : CGFloat.random(in: 0.7...1))
        let s = CGFloat(config.size)
        let r = (0.9 + depth * 3.4) * s * CGFloat.random(in: 0.8...1.15)
        return Flake(x: .random(in: -20...max(1, bounds.width + 20)),
                     y: anywhere ? .random(in: 0...max(1, bounds.height)) : -10,
                     vx: 0, vy: 0,
                     fall: (22 + depth * 62) * CGFloat.random(in: 0.85...1.2),
                     r: r, phase: .random(in: 0...6.28), depth: depth,
                     flutter: CGFloat.random(in: 0.7...2.0) * (1.3 - depth * 0.6),
                     amp: CGFloat.random(in: 6...20) * (1.2 - depth * 0.5),
                     angle: .random(in: 0...6.28), spin: .random(in: -0.8...0.8))
    }

    /// Плавный порывистый ветер: сумма медленных волн, чтобы снег то сносило, то успокаивало.
    private var wind: CGFloat {
        sin(time * 0.21) * 0.6 + sin(time * 0.57 + 1.3) * 0.3 + sin(time * 1.3 + 4.1) * 0.1
    }

    private func step(_ dt: CGFloat) {
        time += dt
        let target = targetCount
        while flakes.filter({ $0.life == .infinity }).count < target && flakes.count < target + 400 {
            var f = spawn(anywhere: flakes.isEmpty); f.vy = f.fall; flakes.append(f)
            if flakes.count > 4000 { break }
        }
        updateCursor()
        let R: CGFloat = 80
        var i = 0
        while i < flakes.count {
            var f = flakes[i]
            f.phase += dt
            f.angle += f.spin * dt
            let flutterX = sin(f.phase * f.flutter) * f.amp + sin(f.phase * f.flutter * 2.3 + 1) * f.amp * 0.3
            let target = flutterX + wind * 34 * (0.35 + f.depth)
            f.vx += (target - f.vx) * min(1, dt * 1.4)
            let bob = sin(f.phase * f.flutter * 1.7) * 5 * (1 - f.depth * 0.5)
            f.vy += (f.fall + bob - f.vy) * min(1, dt * 1.6)
            if f.life != .infinity {
                f.life -= dt
                if f.life <= 0 { flakes.remove(at: i); continue }
            }
            // Курсор отталкивает снежинки
            if config.cursor, let c = cursor {
                let dx = f.x - c.x, dy = f.y - c.y, d2 = dx * dx + dy * dy
                if d2 < R * R, d2 > 0.01 {
                    let d = sqrt(d2), push = (1 - d / R) * 520 * dt
                    f.vx += dx / d * push; f.vy += dy / d * push * 0.6
                }
            }
            let prevY = f.y
            f.x += f.vx * dt; f.y += f.vy * dt
            var landed = false
            if config.onWindows && (f.life == .infinity || f.vy > 0) {
                landed = land(&f, prevY: prevY)
            }
            if landed || f.y > bounds.height + 8 || f.x < -30 || f.x > bounds.width + 30 {
                if f.life != .infinity { flakes.remove(at: i); continue }
                f = spawn(anywhere: false); f.vy = f.fall
            }
            flakes[i] = f
            i += 1
        }
        if config.cursor, let c = cursor { sweep(around: c, radius: R, dt: dt) }
        shedPiles(dt)
        relaxPiles(dt)
    }

    /// Снег съезжает в угол окна и оттуда комками падает вниз, пока сугроб не опустеет.
    private func shedPiles(_ dt: CGFloat) {
        for (id, var p) in piles {
            guard var sh = p.shed else { continue }
            let n = p.h.count
            guard n > 3 else { piles[id] = nil; continue }
            let flow = min(0.9, dt * 14)
            for _ in 0..<4 {   // несколько проходов за кадр — снег пересекает окно за доли секунды
                if sh.dir < 0 { for c in 1..<n { let m = p.h[c] * flow; p.h[c] -= m; p.h[c - 1] += m } }
                else { for c in stride(from: n - 2, through: 0, by: -1) { let m = p.h[c] * flow; p.h[c] -= m; p.h[c + 1] += m } }
            }
            let k = sh.dir < 0 ? 0 : n - 1
            let cols = sh.dir < 0 ? [0, 1, 2] : [n - 1, n - 2, n - 3]
            let heap = cols.reduce(0) { $0 + p.h[$1] }
            sh.emit -= dt; sh.t += dt
            if heap > 3.5, sh.emit <= 0 {
                // Комок срывается с угла окна
                let take = heap * 0.45
                for c in cols { p.h[c] -= p.h[c] * 0.45 }
                let cornerX = sh.dir < 0 ? p.rect.minX + Self.colW * 0.5 : p.rect.maxX - Self.colW * 0.5
                let count = min(9, max(2, Int(take * 1.6)))
                for _ in 0..<count where flakes.count < 4500 {
                    flakes.append(Flake(x: cornerX + sh.dir * .random(in: -2...6), y: p.rect.minY - p.h[k] - .random(in: 0...3),
                                        vx: sh.dir * .random(in: 25...80), vy: .random(in: -25...10), fall: 330,
                                        r: .random(in: 1.6...3.8) * CGFloat(config.size), phase: .random(in: 0...6.28),
                                        depth: 0.8, flutter: 1, amp: 1.5, life: .random(in: 2.2...3.6)))
                }
                sh.emit = 0.05
            }
            // Окно остановилось и комок в углу сброшен — дальше снег копится как обычно
            if !p.ghost, CACurrentMediaTime() > movingUntil, sh.t > 0.35, heap <= 3.5 || sh.t > 2.5 {
                p.shed = nil; piles[id] = p; continue
            }
            if p.mass < 0.35 {
                if p.ghost { piles[id] = nil; continue }
                p.h = [CGFloat](repeating: 0, count: n); p.shed = nil
            } else { p.shed = sh }
            piles[id] = p
        }
    }

    /// Сугроб оседает под собственным весом: крутые склоны выравниваются, получаются мягкие холмики.
    private func relaxPiles(_ dt: CGFloat) {
        let k = min(0.5, dt * 6)
        for (id, p0) in piles where p0.h.count > 2 && p0.shed == nil {
            var h = p0.h
            var changed = false
            for c in 0..<(h.count - 1) {
                let d = h[c] - h[c + 1]
                if abs(d) > 1.1 {
                    let m = (abs(d) - 1.1) * 0.5 * k
                    if d > 0 { h[c] -= m; h[c + 1] += m } else { h[c] += m; h[c + 1] -= m }
                    changed = true
                }
            }
            if changed { piles[id]?.h = h }
        }
    }

    /// Снежинка пересекла поверхность сугроба — добавляем снег в столбец.
    private func land(_ f: inout Flake, prevY: CGFloat) -> Bool {
        for s in surfaces where s.landable && f.x >= s.x0 && f.x < s.x1 {
            guard var h = piles[s.id]?.h else { continue }
            let col = min(h.count - 1, max(0, Int((f.x - s.winX) / Self.colW)))
            let top = s.y - h[col]
            if prevY <= top && f.y >= top {
                let add = f.r * 0.55
                if h[col] < Self.maxPile * CGFloat(config.size.clamped(0.7, 1.6)) {
                    h[col] += add
                    if col > 0 { h[col - 1] += add * 0.45 }
                    if col + 1 < h.count { h[col + 1] += add * 0.45 }
                    piles[s.id]?.h = h
                } else if col > 1, col + 2 < h.count {
                    // Столбец полный — снег сползает на более низкого соседа
                    let side = h[col - 1] <= h[col + 1] ? col - 1 : col + 1
                    h[side] += add * 0.6
                    piles[s.id]?.h = h
                }
                return true
            }
        }
        return false
    }

    /// Курсор сметает сугроб и подбрасывает снег в стороны.
    private func sweep(around c: CGPoint, radius R: CGFloat, dt: CGFloat) {
        for s in surfaces {
            guard c.y > s.y - R, c.y < s.y + 24, var h = piles[s.id]?.h else { continue }
            var touched = false
            let lo = max(s.x0, c.x - R), hi = min(s.x1, c.x + R)
            guard lo < hi else { continue }
            let c0 = max(0, Int((lo - s.winX) / Self.colW)), c1 = min(h.count - 1, Int((hi - s.winX) / Self.colW))
            guard c0 <= c1 else { continue }
            for col in c0...c1 where h[col] > 0.2 {
                let x = s.winX + CGFloat(col) * Self.colW
                let k = 1 - min(1, abs(x - c.x) / R)
                let removed = min(h[col], (3 + h[col] * 4) * k * dt * 6)
                h[col] -= removed
                touched = true
                if flakes.count < 4500, CGFloat.random(in: 0...1) < min(1, removed * 2) {
                    let dir: CGFloat = x >= c.x ? 1 : -1
                    flakes.append(Flake(x: x, y: s.y - h[col] - 1, vx: dir * .random(in: 60...180), vy: .random(in: -140 ... -40),
                                        fall: 40, r: .random(in: 1.2...2.6) * CGFloat(config.size), phase: .random(in: 0...6.28),
                                        life: .random(in: 0.8...1.8)))
                }
            }
            if touched { piles[s.id]?.h = h }
        }
    }

    private func updateCursor() {
        let m = NSEvent.mouseLocation
        let x = m.x - screenOrigin.x, y = screenHeight - (m.y - screenOrigin.y)
        cursor = (x >= 0 && x <= bounds.width && y >= 0 && y <= bounds.height) ? CGPoint(x: x, y: y) : nil
    }

    // MARK: Рисование

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.clear(bounds)
        if config.garlands { drawGarlands(ctx) }
        drawPiles(ctx)
        drawFlakes(ctx)
    }

    // Заранее нарисованные спрайты: мягкий диск (боке) и шестилучевой кристалл
    private static let softSprite: CGImage? = makeSprite(size: 64) { ctx, c in
        let g = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [
            CGColor(gray: 1, alpha: 1), CGColor(gray: 1, alpha: 0.85), CGColor(gray: 1, alpha: 0.28), CGColor(gray: 1, alpha: 0)] as CFArray,
            locations: [0, 0.3, 0.7, 1])!
        ctx.drawRadialGradient(g, startCenter: c, startRadius: 0, endCenter: c, endRadius: 32, options: [])
    }

    private static let crystalSprite: CGImage? = makeSprite(size: 96) { ctx, c in
        ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.95)); ctx.setLineCap(.round)
        for i in 0..<6 {
            ctx.saveGState()
            ctx.translateBy(x: c.x, y: c.y); ctx.rotate(by: CGFloat(i) * .pi / 3)
            ctx.setLineWidth(3.2); ctx.move(to: .zero); ctx.addLine(to: CGPoint(x: 0, y: 36)); ctx.strokePath()
            ctx.setLineWidth(2.2)
            for (y, l) in [(16.0, 9.0), (26.0, 6.0)] as [(CGFloat, CGFloat)] {
                ctx.move(to: CGPoint(x: 0, y: y)); ctx.addLine(to: CGPoint(x: -l, y: y + l * 0.8))
                ctx.move(to: CGPoint(x: 0, y: y)); ctx.addLine(to: CGPoint(x: l, y: y + l * 0.8))
            }
            ctx.strokePath()
            ctx.restoreGState()
        }
        softSprite.map { ctx.setAlpha(0.8); ctx.draw($0, in: CGRect(x: c.x - 14, y: c.y - 14, width: 28, height: 28)) }
    }

    private static func makeSprite(size: Int, _ draw: (CGContext, CGPoint) -> Void) -> CGImage? {
        guard let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        draw(ctx, CGPoint(x: CGFloat(size) / 2, y: CGFloat(size) / 2))
        return ctx.makeImage()
    }

    private func drawFlakes(_ ctx: CGContext) {
        guard let soft = Self.softSprite else { return }
        let crystal = Self.crystalSprite
        // Далёкие рисуем первыми — ближние перекрывают их
        for pass in 0..<2 {
            for f in flakes {
                let near = f.depth > 0.72 && f.r > 3.2 && crystal != nil
                guard near == (pass == 1) else { continue }
                let fade: CGFloat = f.life == .infinity ? 1 : min(1, f.life * 1.5)
                let a = (0.38 + f.depth * 0.6) * fade
                if near, let crystal {
                    let d = f.r * 3.0
                    ctx.saveGState()
                    ctx.setAlpha(a * 0.9)
                    ctx.translateBy(x: f.x, y: f.y); ctx.rotate(by: f.angle); ctx.scaleBy(x: 1, y: -1)   // вью перевёрнут
                    ctx.draw(crystal, in: CGRect(x: -d / 2, y: -d / 2, width: d, height: d))
                    ctx.restoreGState()
                } else {
                    // Очень близкие без кристалла — размытые «боке»: крупнее и прозрачнее
                    let blur: CGFloat = f.depth > 0.85 ? 1.9 : 1.0
                    let d = f.r * 2.6 * blur
                    ctx.setAlpha(a * (blur > 1 ? 0.5 : 1))
                    ctx.draw(soft, in: CGRect(x: f.x - d / 2, y: f.y - d / 2, width: d, height: d))
                }
            }
        }
        ctx.setAlpha(1)
    }

    private func drawPiles(_ ctx: CGContext) {
        guard config.onWindows else { return }
        let space = CGColorSpaceCreateDeviceRGB()
        let grad = CGGradient(colorsSpace: space, colors: [
            CGColor(red: 1, green: 1, blue: 1, alpha: 0.98), CGColor(red: 0.86, green: 0.92, blue: 1, alpha: 0.96)] as CFArray,
            locations: [0, 1])!
        for s in surfaces {
            guard let h = piles[s.id]?.h, !h.isEmpty else { continue }
            let c0 = max(0, Int((s.x0 - s.winX) / Self.colW)), c1 = min(h.count - 1, Int((s.x1 - s.winX) / Self.colW))
            guard c0 < c1 else { continue }
            let p = CGMutablePath(), edge = CGMutablePath()
            p.move(to: CGPoint(x: s.winX + CGFloat(c0) * Self.colW, y: s.y + 0.5))
            for col in c0...c1 {
                // Сглаживание по пяти столбцам + неподвижная «рябь», чтобы край не был линейкой
                let a = h[max(0, col - 2)], b = h[max(0, col - 1)], m = h[col], d = h[min(h.count - 1, col + 1)], e = h[min(h.count - 1, col + 2)]
                let ripple = m > 0.6 ? sin(CGFloat(col) * 1.7 + CGFloat(s.id % 17)) * 0.35 : 0
                let pt = CGPoint(x: s.winX + (CGFloat(col) + 0.5) * Self.colW, y: s.y - (a + 2 * b + 3 * m + 2 * d + e) / 9 - ripple)
                p.addLine(to: pt)
                if col == c0 { edge.move(to: pt) } else { edge.addLine(to: pt) }
            }
            p.addLine(to: CGPoint(x: s.winX + CGFloat(c1) * Self.colW, y: s.y + 0.5))
            p.closeSubpath()
            ctx.saveGState()
            ctx.addPath(p); ctx.clip()
            ctx.drawLinearGradient(grad, start: CGPoint(x: 0, y: s.y - Self.maxPile - 4), end: CGPoint(x: 0, y: s.y + 1), options: [])
            ctx.restoreGState()
            // Блик на гребне и мягкая тень, чтобы сугроб казался объёмным
            ctx.setLineJoin(.round); ctx.setLineCap(.round)
            ctx.setStrokeColor(CGColor(gray: 1, alpha: 0.9)); ctx.setLineWidth(1.3)
            ctx.addPath(edge); ctx.strokePath()
            // Редкие искорки на снегу
            let t = time * 2.4
            for k in 0..<3 {
                let col = c0 + Int(abs(sin(CGFloat(k) * 12.9898 + CGFloat(Int(t / 2) + s.id) * 78.233)) * CGFloat(c1 - c0))
                guard col < h.count, h[col] > 2 else { continue }
                let tw = max(0, sin(t * 1.3 + CGFloat(k) * 2.1))
                let x = s.winX + (CGFloat(col) + 0.5) * Self.colW, y = s.y - h[col]
                ctx.setFillColor(CGColor(gray: 1, alpha: tw))
                ctx.fill(CGRect(x: x - 0.6, y: y - 3 * tw, width: 1.2, height: 6 * tw))
                ctx.fill(CGRect(x: x - 3 * tw, y: y - 0.6, width: 6 * tw, height: 1.2))
            }
        }
    }

    private static let bulbColors: [CGColor] = [
        CGColor(red: 1.00, green: 0.25, blue: 0.25, alpha: 1), CGColor(red: 1.00, green: 0.72, blue: 0.20, alpha: 1),
        CGColor(red: 0.30, green: 0.90, blue: 0.45, alpha: 1), CGColor(red: 0.35, green: 0.70, blue: 1.00, alpha: 1),
        CGColor(red: 0.95, green: 0.45, blue: 0.95, alpha: 1)]

    /// Гирлянда провисающими дугами вдоль верхнего края экрана (под строкой меню).
    private func drawGarlands(_ ctx: CGContext) {
        let y0 = menuBarHeight + 1
        let span = max(160, bounds.width / CGFloat(max(3, Int(bounds.width / 260))))
        let n = Int((bounds.width / span).rounded(.up))
        ctx.setLineWidth(1.4)
        ctx.setStrokeColor(CGColor(red: 0.07, green: 0.2, blue: 0.1, alpha: 0.9))
        var idx = 0
        for k in 0..<n {
            let xa = CGFloat(k) * span, xb = min(bounds.width, xa + span)
            let sag: CGFloat = 26
            func pt(_ t: CGFloat) -> CGPoint {
                CGPoint(x: xa + (xb - xa) * t, y: y0 + sag * 4 * t * (1 - t))   // парабола
            }
            ctx.beginPath(); ctx.move(to: pt(0))
            for j in 1...24 { ctx.addLine(to: pt(CGFloat(j) / 24)) }
            ctx.strokePath()
            let bulbs = max(4, Int((xb - xa) / 24))
            for b in 0...bulbs {
                let p = pt(CGFloat(b) / CGFloat(bulbs))
                let tw = 0.6 + 0.4 * sin(time * 2.2 + CGFloat(idx) * 1.7)
                let col = Self.bulbColors[idx % Self.bulbColors.count]
                ctx.setFillColor(col.copy(alpha: 0.18 * tw) ?? col)
                ctx.fillEllipse(in: CGRect(x: p.x - 8, y: p.y - 4, width: 16, height: 16))
                ctx.setFillColor(col.copy(alpha: 0.55 + 0.45 * tw) ?? col)
                ctx.fillEllipse(in: CGRect(x: p.x - 3, y: p.y + 1, width: 6, height: 8))
                idx += 1
            }
        }
    }
}

private extension Double {
    func clamped(_ lo: Double, _ hi: Double) -> Double { Swift.min(hi, Swift.max(lo, self)) }
}

// MARK: - Окно-оверлей одного экрана

@MainActor
final class SnowOverlay {
    let screenKey: String
    let window: NSWindow
    let canvas: SnowCanvas
    let cgBounds: CGRect

    init(info: WallpaperEngine.ScreenInfo, screen: NSScreen?) {
        screenKey = info.key
        cgBounds = info.cgBounds
        let w = NSWindow(contentRect: info.frame, styleMask: .borderless, backing: .buffered, defer: false)
        w.isOpaque = false
        w.backgroundColor = .clear
        w.hasShadow = false
        w.ignoresMouseEvents = true          // клики проходят насквозь
        w.level = .floating
        w.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        w.isReleasedWhenClosed = false
        let c = SnowCanvas(frame: CGRect(origin: .zero, size: info.frame.size))
        c.autoresizingMask = [.width, .height]
        c.screenOrigin = info.frame.origin
        c.screenHeight = info.frame.height
        if let screen { c.menuBarHeight = max(0, screen.frame.maxY - screen.visibleFrame.maxY) }
        w.contentView = c
        window = w
        canvas = c
        w.setFrame(info.frame, display: false)
    }

    func show() { window.orderFrontRegardless(); canvas.startLoop() }
    func hide() { canvas.pauseLoop(); window.orderOut(nil) }
    func close() { canvas.stopLoop(); window.orderOut(nil); window.contentView = nil }
}

// MARK: - Контроллер

/// Управляет оверлеями: включение, пауза (отдельно от обоев), опрос окон.
@MainActor
final class SnowController {
    weak var app: AppState?
    private var overlays: [String: SnowOverlay] = [:]
    private var scanTimer: Timer?
    private var screenObserver: NSObjectProtocol?
    private var paused: Set<String> = []

    private var enabled: Bool { app?.settings.snowEnabled ?? false }

    func start() {
        if screenObserver == nil {
            screenObserver = NotificationCenter.default.addObserver(
                forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { self?.rebuild() }
            }
        }
        rebuild()
    }

    func shutdown() {
        scanTimer?.invalidate(); scanTimer = nil
        overlays.values.forEach { $0.close() }
        overlays = [:]
    }

    func settingsChanged() { rebuild() }

    func clearSnow() { overlays.values.forEach { $0.canvas.clearSettledSnow() } }

    private var config: SnowConfig {
        let s = app?.settings ?? AppSettings()
        return SnowConfig(density: s.snowDensity, size: s.snowSize, onWindows: s.snowOnWindows,
                          cursor: s.snowCursor, garlands: s.snowGarlands,
                          lowPower: ProcessInfo.processInfo.isLowPowerModeEnabled)
    }

    private func rebuild() {
        guard enabled, let engine = app?.engine else { shutdown(); return }
        let infos = engine.screens
        // Убираем оверлеи пропавших экранов
        for (k, o) in overlays where !infos.contains(where: { $0.key == k }) { o.close(); overlays[k] = nil }
        for info in infos {
            let screen = NSScreen.screens.first { $0.frame == info.frame }
            if let o = overlays[info.key], o.window.frame == info.frame {
                o.canvas.config = config
                continue
            }
            overlays[info.key]?.close()
            let o = SnowOverlay(info: info, screen: screen)
            o.canvas.config = config
            overlays[info.key] = o
        }
        if scanTimer == nil { scheduleScan(after: 0.1) }
        updatePause()
    }

    /// 10 раз в секунду в покое и 30, пока окна двигаются или сугробы осыпаются: так сугроб не отстаёт от окна.
    private func scheduleScan(after delay: TimeInterval) {
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.scan() }
        }
    }

    private func scan() {
        guard enabled else { return }
        var fast = false
        if config.onWindows {
            for (k, o) in overlays where !paused.contains(k) {
                o.canvas.updateWindows(SnowWindowScan.windows(on: o.cgBounds))
                fast = fast || o.canvas.windowsAreMoving
            }
        }
        scheduleScan(after: fast ? 1.0 / 30 : 0.1)
    }

    /// Паузы снега не зависят от пауз обоев: у каждого свои переключатели в настройках.
    func updatePause() {
        guard let app, enabled else { return }
        let s = app.settings, m = app.monitor
        let reduce = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        let global = reduce
            || (s.snowPauseOnBattery && m.onBattery)
            || (s.snowPauseOnLock && (m.isLocked || m.isAsleep))
        var now = Set<String>()
        for (k, o) in overlays {
            let p = global
                || (s.snowPauseOnFullscreen && m.fullscreenScreens.contains(k))
                || (s.snowPauseOnMaximized && m.maximizedScreens.contains(k))
            if p { now.insert(k) }
            if p { o.hide() } else { o.show() }
        }
        paused = now
    }
}
