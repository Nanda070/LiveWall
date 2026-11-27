# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [SemVer](https://semver.org/).

## [Unreleased]

### Fixed
- **A wrong Steam password now says so.** steamcmd reports it as `ERROR (Invalid Password)`, which the sign-in screen didn't recognize, so it showed only “Sign-in failed (code 5)”. It now shows “Wrong login or password”.
- **steamcmd without Rosetta 2 gets a clear message.** Valve ships steamcmd for Intel only, so on Apple Silicon without Rosetta 2 it couldn't start and sign-in failed with “code 126”. Installing steamcmd, signing in and downloading from the Workshop now check for Rosetta first and tell you the command that installs it.
- **`build.sh` works with Command Line Tools on macOS 27.** The unsigned-build message broke the script at the signing step, and the macOS 27 SDK can't compile `@State` without Xcode. Without Xcode the script now builds against the newest SDK below 27.

## [1.7.2] — 2026-11-25

### Fixed
- **“Pause all wallpapers” really survives a restart now.** While starting, LiveWall briefly wrote “pause off” to disk before restoring the saved value, and a second copy launched at the same moment (login, restart, reopening the app) could read that and keep it. LiveWall now only reads its state until startup is complete, and extra copies never write anything.

### Changed
- Credits scroll twice as fast and name Nijat Afandiyev for idea and production.

## [1.7.1] — 2026-11-25

### Fixed
- **Workshop sync no longer fails with “NSURLErrorDomain error -999”.** Steam redirects the subscriptions page on the way (`/my/…` → `/id/<name>/…`), and LiveWall took the interrupted first load for an error. It now waits for the final page, and gives a clear message if Steam doesn't answer within 45 seconds.
- **Wallpaper Engine scenes with a video background no longer show gray noise.** Such scenes keep an mp4 inside the texture, and the converter read it as pixels. A full-screen video texture is now extracted and the wallpaper is imported as a video wallpaper (layers on top of the video, usually particles, are not carried over). Re-import a scene that already shows noise: delete it from the library and sync again.

## [1.7.0] — 2026-11-25

### Added
- **Holiday theme** (Settings → Appearance, on by default): candy-cane red and white palette, candy stripes on the selected sidebar item, primary buttons and page headers, a twinkling garland of red and white bulbs along the top of the window, and crossed candy canes with holly next to the logo. The twinkling runs on Core Animation, so it doesn't redraw the interface.

### Performance
- **Scenes render natively on Metal** instead of WebKit (Settings → Performance → “Scenes on Metal”, on by default). The same layers, parallax, particles, text and widgets, waves, glow, color grading, blend modes and weather tinting, drawn straight into a `CAMetalLayer` without a WebKit process or the JavaScript bridge. On a 4K Wallpaper Engine scene at 60 FPS the load dropped from about 20% to 4–6% CPU. Shaders and web wallpapers still use WebKit; the scene editor too. If Metal is unavailable or a scene can't be read, LiveWall falls back to WebKit by itself.
- **Smart FPS** (on by default): when nothing happens, wallpapers draw at most 20 fps; on mouse movement and music beats they go up to your FPS limit for a moment. With a 60 FPS limit a Metal scene uses about 1.6% CPU at rest.

### Fixed
- **“Pause all wallpapers” is kept after a restart.** It used to reset every time LiveWall started.
- **The lock screen wallpaper can be turned off.** Turning off “Same wallpaper on the lock screen” now brings back the desktop picture you had before LiveWall and deletes its still frames; previously the last frame stayed. The setting has its own Lock screen section in Settings and a toggle in the menu bar menu.

## [1.6.2] — 2026-11-25

### Added
- **Same wallpaper on the lock screen** (Settings → Displays, on by default). A few seconds after a wallpaper changes, LiveWall sets a full-resolution still frame of it as the system desktop picture, which macOS shows on the lock screen.
- **Snow toggle in the menu bar menu.**
- The Snow tab says why snow is paused right now, and Reduce Motion is now its own pause setting.

### Fixed
- **Snow didn't show at all with Reduce Motion on:** it was silently stopped. Reduce Motion now pauses snow only if you turn that setting on.
- **Snow used about a quarter of the CPU:** the whole screen was redrawn and sent to the system every frame. Flakes and drifts are now Core Animation layers composited by the GPU; snow costs about 1–2% CPU.
- **A white strip stayed for seconds after closing a window:** its drift now collapses in about half a second, without the highlight line.
- **Wallpapers went blank when WebKit restarted or lost its WebGL context** (for example under memory pressure): they now reload by themselves with their FPS, settings and volume, up to 5 times in 5 minutes.

## [1.6.1] — 2026-11-24

Snow polish by [@Nanda070](https://github.com/Nanda070) in [#2](https://github.com/Jinjer07/LiveWall/pull/2).

### Changed
- **Snow drifts:** they build up faster and taper toward the edges of a window. The mouse pointer now plows snow aside into ridges instead of removing it. Flakes are soft round discs with a calmer sway.
- **Moving or closing a window:** its drift no longer travels with the window. It stays in place and collapses from the corner, and window frames are polled at 30 Hz while something moves, so drifts do not lag.

### Fixed
- An empty window edge was drawn as a white line. Only drifts that actually hold snow are drawn now.
- With Stage Manager on, macOS reports untransformed window frames, so drifts hung in the air. Snow no longer settles on windows while Stage Manager is on (the Snow tab says so).

## [1.6.0] — 2026-11-24

Most of this release was contributed by [@Nanda070](https://github.com/Nanda070) in [#1](https://github.com/Jinjer07/LiveWall/pull/1).

### Added
- **Snow tab:** snow over the desktop. Three depth layers, gusty wind, crystals on the nearest flakes, soft drifts on the top edges of windows that move with the window, the cursor pushes flakes and sweeps drifts, string lights under the menu bar. The transparent layer never catches clicks. Off by default.
- **Separate pause settings for snow and wallpapers** (battery, full-screen app, maximized window, lock and sleep), on the Snow tab. Snow also stops under Reduce Motion and halves its density in Low Power Mode.
- **Multi-select in the library:** Cmd-click, Shift-click, Cmd+A and a selection bar (favorite, delete). **Cmd+Backspace** deletes the selection after a confirmation; the files go to the Trash.
- **Playlists start on launch** (the last active one, or the last chosen one if no wallpaper is set) instead of after the first interval.

### Fixed
- **Huge text in imported Wallpaper Engine scenes** (“Date” and “D a y” overlapping): for tall text boxes the font size came from the box height. They now use `pointsize`, and sizes are clamped to the editor's range. Re-import affected scenes to apply the fix.
- **Delay when clicking a wallpaper:** the pair of single-click and double-click handlers made SwiftUI wait out the double-click interval. Selection is now instant.
- **Cmd+Backspace in the library search field** no longer opens “Delete selected wallpapers?”. The shortcut only works while the wallpaper grid has focus, so in text fields it deletes to the start of the line as usual.

### Docs
- All documentation is now in English; the Russian README is in [README.ru.md](README.ru.md).

## [1.5.0] — 2026-11-24

### Added
- **Pause when another app is focused** (Settings → Performance). Wallpapers play only while you are on the desktop (Finder) or in LiveWall. Off by default.

### Fixed
- **The “Find” button for the weather city:** on macOS 27 the text field in Settings was invisible, so the search looked broken. The field now has a border and a hint, Enter searches too, and the button is disabled while the field is empty.
- The same fix for invisible text fields in Workshop (Steam login, steamcmd path, ID/link), Playlists (name) and the scene editor (layer name, text).

## [1.4.1] — 2026-11-24

### Performance
- The audio meter on the “Now” card and the pulsing LIVE dot are drawn with Core Animation layers and no longer redraw the SwiftUI interface. CPU with the window open dropped from about 17% to 4%.

## [1.4.0] — 2026-11-24

Testing and fixes on macOS 27.

### Changed
- **Audio reactivity through a Core Audio system tap** (macOS 14.2+): only the “System Audio Recording Only” permission is needed instead of “Screen Recording”, and the screen is not captured. Older systems keep using ScreenCaptureKit.

### Fixed
- **Two copies of the app at once** (window restoration after a reboot plus launch at login): wallpapers were drawn twice and the load doubled. The second copy now hands over to the first and quits.
- **Signing out of Steam** no longer touches the regular Steam client's files; it only resets the sign-in of the steamcmd that LiveWall installed.
- **Workshop wallpapers you deleted** no longer come back on sync; “Import all” brings them back explicitly.
- **False Steam sign-in errors:** only steamcmd lines with `FAILED (…)` and `ERROR!` count as errors.
- **Black covers** for wallpapers whose Workshop preview is a GIF with a dark first frame: the middle frame is used.
- **Interface:** wrapping of “Library” and its counter in the sidebar, pages overlapping while switching sections, wrapping of the “Sync Workshop” button, system buttons in Workshop restyled to match the app, Settings shows the real version instead of “LiveWall 1.0”.
- **Install instructions** for macOS 15+ (Gatekeeper: “Open Anyway”).

## [1.3.1] — 2026-11-24

### Fixed
- The system prompt “LiveWall would like to record the screen and audio” no longer appears on every launch. Without permission, LiveWall quietly shows “Grant access” and “Relaunch LiveWall” buttons in Settings, and the macOS prompt appears only when you press them or turn on audio reactivity.

## [1.3.0] — 2026-11-24

### Added
- **Steam sign-in inside LiveWall**, no Terminal needed: username and password, then a Steam Mobile confirmation or a Steam Guard code. Under the hood the official steamcmd runs in a hidden pseudo-terminal; the password goes only to it and is never stored.
- **One-click steamcmd install** (Valve's official archive, no Homebrew).
- **“Sync Workshop”**: LiveWall fetches your Wallpaper Engine subscriptions itself (through a built-in steamcommunity.com window, QR sign-in from Steam Mobile), downloads new ones, converts scenes and adds everything to the “Wallpaper Engine” playlist.
- “Sign out” clears the saved steamcmd sign-in and Steam cookies.

## [1.2.2] — 2026-11-24

### Fixed
- macOS no longer asks for permissions (“Screen & System Audio Recording”, “Calendars”) again after every update. The app is signed with a stable certificate, so the system recognizes it by certificate rather than by the fingerprint of a particular build. After installing 1.2.2 the permission has to be granted one last time.

## [1.2.1] — 2026-11-24

### Fixed
- Clicking the LiveWall icon in the Dock, Launchpad or Finder while the app runs in the background now opens the main window (macOS used to just show the desktop).

## [1.2.0] — 2026-11-24

### Added
- **Wallpaper Engine scene converter.** Unpacks `scene.pkg` and `.tex` textures (LZ4, DXT1/3/5, RGBA, embedded JPG/PNG), keeps images at their original resolution and builds a LiveWall scene: layers, depth parallax, particles (rain, snow, ash, sparks…), blend modes, text clocks and similar effects.
- WE GIF scenes become animated GIF wallpapers; pixel art scales without blurring.
- Workshop presets: settings and their own files on top of the base web project.
- An “Import all and create a playlist” button in Workshop.

### Limitations
- WE puppet animation of characters and custom WE shaders are not converted: those layers stay static.

## [1.1.0] — 2026-11-24

### Added
- **Gallery**: 6 scenes and 6 shaders from the repository, one-click install, cached previews.
- **Time of day and weather**: scenes get darker at night, warmer at sunset and show rain or snow from Open-Meteo weather. Shaders get `iAmbient`, web wallpapers get the `lw-ambient` event.
- **Widgets**: tokens `{cpu}` `{ram}` `{battery}` `{charging}` `{track}` `{artist}` `{event}` `{eventTime}` `{temp}` `{weather}` `{city}` and presets in the scene editor.
- **Auto-updates through GitHub Releases**: banner, download with progress, SHA-256 check, app swap and relaunch.
- **English interface**: switches on the fly; dates in scenes are translated too.

### Performance
- Previews are decoded in the background with an LRU cache of 200 images.
- Cursor polling and system data collection run only while wallpapers are visible.
- Endless animations remain only where they are needed; the audio meter updates at most 12 times a second.

## [1.0.0] — 2026-11-24

First stable release.

### Added
- App icon (generated by `tools/make_icon.swift`).
- Documentation: README, user guide, wallpaper formats, architecture.

## [0.9.0-beta] — 2026-11-24

Full functionality and redesign, without the icon and docs.

### Features
- Desktop engine: video, web, images and GIFs, slideshows, GLSL shaders, scenes; multiple displays and a “stretch” mode.
- Wallpaper Engine web wallpaper API, import of Steam Workshop projects and downloads through steamcmd.
- Scene editor: layers, particles, parallax, waves, glow, color grading, clock and date.
- System audio reactivity (ScreenCaptureKit + vDSP FFT).
- Library with tags and favorites, playlists by timer and time of day, `.wallpkg` packages, launch at login.
- Charcoal and crimson design: custom sidebar with a mini player, animated cards and chips, splash screen, terms of use, credits, 7-page onboarding.

### Performance
- Scene load cut from about 42% to 6% CPU:
  - 15 FPS limit by default and an adaptive boost to 30 FPS on mouse movement;
  - 1× rendering, an opaque WebView, no `preserveDrawingBuffer`;
  - pause when windows cover ≥85% of the desktop;
  - the SwiftUI interface is unloaded while the window is closed.

### Fixed
- WebKit didn't call `requestAnimationFrame` in the desktop window; added a custom frame scheduler.
- Assigned wallpapers were reset on launch.
- Global mouse monitoring asked for Accessibility access; the cursor is now polled without permissions.

[Unreleased]: https://github.com/Jinjer07/LiveWall/compare/v1.7.2...HEAD
[1.7.2]: https://github.com/Jinjer07/LiveWall/compare/v1.7.1...v1.7.2
[1.7.1]: https://github.com/Jinjer07/LiveWall/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/Jinjer07/LiveWall/compare/v1.6.2...v1.7.0
[1.6.2]: https://github.com/Jinjer07/LiveWall/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/Jinjer07/LiveWall/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/Jinjer07/LiveWall/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/Jinjer07/LiveWall/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/Jinjer07/LiveWall/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/Jinjer07/LiveWall/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/Jinjer07/LiveWall/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/Jinjer07/LiveWall/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/Jinjer07/LiveWall/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/Jinjer07/LiveWall/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/Jinjer07/LiveWall/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/Jinjer07/LiveWall/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Jinjer07/LiveWall/compare/v0.9.0-beta...v1.0.0
[0.9.0-beta]: https://github.com/Jinjer07/LiveWall/releases/tag/v0.9.0-beta
