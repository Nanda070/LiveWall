// Таблица переводов RU → EN. Формат строки: «русский ||| english». \n — перевод строки.
enum LocEN {
    static let table = #"""
ДЕТАЛИ ||| DETAILS
Название ||| Title
Теги через запятую ||| Tags, comma separated
НАСТРОЙКИ ОБОЕВ ||| WALLPAPER SETTINGS
Сбросить настройки ||| Reset settings
Удалить «%@»? ||| Delete “%@”?
Удалить ||| Delete
Файлы обоев будут перемещены в Корзину. ||| Wallpaper files will be moved to the Trash.
Обои будут убраны из библиотеки, исходные файлы останутся на месте. ||| The wallpaper will be removed from the library; the original files stay in place.
Применено: %@ ||| Applied: %@
Растянуть на все экраны ||| Span across all displays
Применить на все экраны ||| Apply to all displays
Steam не ответил вовремя. Попробуйте ещё раз. ||| Steam didn’t respond in time. Please try again.
это видеотекстура, а не картинка ||| this is a video texture, not an image
видеослой «%@» не переносится ||| video layer “%@” isn’t carried over
слои поверх видео не переносятся ||| layers on top of the video aren’t carried over
Снять с рабочего стола ||| Remove from desktop
Открыть в редакторе сцен ||| Open in Scene Editor
Редактировать код шейдера ||| Edit shader code
Превью обновлено ||| Preview updated
Сначала примените обои — превью снимается с рабочего стола ||| Apply the wallpaper first — the preview is captured from the desktop
Обновить превью с рабочего стола ||| Update preview from desktop
Перезапустить обои ||| Restart wallpaper
Показать в Finder ||| Show in Finder
Экспортировано ||| Exported
Ошибка: %@ ||| Error: %@
Экспорт в .wallpkg ||| Export to .wallpkg
Код шейдера ||| Shader code
Изменения применяются к обоям на рабочем столе. ||| Changes are applied to the wallpaper on your desktop.
Закрыть ||| Close
Сохранить и применить ||| Save & Apply
Плейлисты ||| Playlists
Смена обоев по таймеру или по времени суток ||| Change wallpapers on a timer or by time of day
Плейлист %@ ||| Playlist %@
Новый плейлист ||| New playlist
Нет плейлиста ||| No playlist
Создайте плейлист кнопкой «+»: обои будут меняться по таймеру или по времени суток. ||| Create a playlist with “+”: wallpapers will change on a timer or by time of day.
Режим ||| Mode
По таймеру ||| On a timer
По времени суток ||| By time of day
Остановить ||| Stop
Запустить плейлист ||| Start playlist
Следующие ||| Next
Смена обоев ||| Rotation
Интервал ||| Interval
%@ мин ||| %@ min
%@ ч ||| %@ h
Случайный порядок ||| Shuffle
Удалённые обои ||| Deleted wallpaper
Добавить обои… ||| Add wallpapers…
Обои (%@) ||| Wallpapers (%@)
Добавить время ||| Add time
Расписание ||| Schedule
С указанного времени и до следующего пункта стоят выбранные обои. Например: 07:00 — утро, 19:00 — вечер, 23:00 — ночь. ||| From each time until the next entry, the chosen wallpaper is shown. For example: 07:00 morning, 19:00 evening, 23:00 night.
Выберите обои ||| Choose wallpapers
Поиск ||| Search
Выбрано: %@ ||| Selected: %@
Отмена ||| Cancel
Готово ||| Done
Настройки ||| Settings
Производительность, звук, мониторы и система ||| Performance, sound, displays and system
Живые обои для macOS ||| Live wallpapers for macOS
Гайд ||| Guide
Условия ||| Terms
Титры ||| Credits
Показывать заставку при запуске ||| Show intro animation on launch
Язык ||| Language
Язык интерфейса ||| Interface language
Как в системе ||| System
Русский ||| Русский
Производительность ||| Performance
Ограничение FPS ||| Frame rate limit
15 кадров/с (экономно) ||| 15 fps (power saving)
%@ кадров/с ||| %@ fps
Пауза, когда приложение открыто на весь экран ||| Pause when an app is full screen
Пауза, когда окно развёрнуто почти на весь экран ||| Pause when a window is maximized
Пауза, когда рабочий стол закрыт окнами (экономия CPU) ||| Pause when the desktop is covered by windows (saves CPU)
Пауза при работе от батареи ||| Pause on battery power
Пауза при блокировке экрана и сне дисплея ||| Pause when locked or display is asleep
Пауза всех обоев ||| Pause all wallpapers
Звук обоев ||| Wallpaper sound
Без звука ||| Mute
Громкость ||| Volume
Звук воспроизводится только с основного монитора. ||| Sound plays from the main display only.
Обои реагируют на системный звук ||| Wallpapers react to system audio
Состояние ||| Status
Открыть настройки конфиденциальности ||| Open Privacy settings
Аудио-визуализация ||| Audio visualization
Для захвата системного звука macOS требует разрешение «Запись экрана и системного звука». Видео при этом не записывается. Спектр доступен веб-обоям (wallpaperRegisterAudioListener), шейдерам (iAudio, iSpectrum) и сценам. ||| macOS requires the “Screen & System Audio Recording” permission to capture system audio. No video is recorded. The spectrum is available to web wallpapers (wallpaperRegisterAudioListener), shaders (iAudio, iSpectrum) and scenes.
Интерактивность ||| Interactivity
Обои реагируют на движение мыши (параллакс, эффекты) ||| Wallpapers react to the mouse (parallax, effects)
Передавать клики по рабочему столу в обои ||| Pass desktop clicks to wallpapers
Адаптировать сцены к времени суток и погоде ||| Adapt scenes to time of day and weather
Город для погоды ||| City for weather
Найти ||| Find
Сбросить ||| Reset
Время суток и погода ||| Time of day & weather
Сцены с включённой адаптацией темнеют ночью, теплеют на закате, а в дождь и снег показывают осадки. Погода — Open-Meteo: туда отправляется только название города и координаты. ||| Adaptive scenes get darker at night, warmer at sunset and show rain or snow when it falls outside. Weather comes from Open-Meteo; only the city name and coordinates are sent.
«Сейчас играет» из Музыки, Spotify и браузеров ||| “Now playing” from Music, Spotify and browsers
Ближайшее событие из Календаря ||| Next event from Calendar
Виджеты ||| Widgets
Виджеты — это текстовые слои сцены с токенами: {cpu} {ram} {battery} {track} {artist} {event} {eventTime} {temp} {weather} {city}. Готовые пресеты — в редакторе сцен, кнопка «+» → «Виджет». ||| Widgets are scene text layers with tokens: {cpu} {ram} {battery} {track} {artist} {event} {eventTime} {temp} {weather} {city}. Ready-made presets are in the Scene Editor: “+” → “Widget”.
Мониторы ||| Displays
Растянуть одни обои на все мониторы ||| Span one wallpaper across all displays
Система ||| System
Запускать при входе в систему ||| Launch at login
Автозапуск работает только для собранного LiveWall.app. ||| Launch at login only works for the built LiveWall.app.
Открыть папку данных ||| Open data folder
Добавить примеры заново ||| Re-add samples
Новая сцена ||| New scene
Не удалось скопировать %@: %@ ||| Couldn’t copy %@: %@
Текст ||| Text
Заливка ||| Fill
 (копия) |||  (copy)
Ошибка сохранения: %@ ||| Save error: %@
Сцена сохранена и применена ||| Scene saved and applied
Сцена сохранена ||| Scene saved
Редактор сцен ||| Scene Editor
Редактирование: %@ ||| Editing: %@
Новая ||| New
Сохранить ||| Save
Название сцены ||| Scene name
Параллакс в превью ||| Parallax in preview
Не сохранено ||| Unsaved
Перетаскивайте слои мышью прямо в превью. Текстовые токены: {time} {time:s} {date} {weekday} {year} ||| Drag layers right in the preview. Text tokens: {time} {time:s} {date} {weekday} {year}
Слои ||| Layers
Изображение… ||| Image…
Частицы ||| Particles
Текст / часы ||| Text / clock
Цветная заливка ||| Color fill
Виджет ||| Widget
Выше ||| Move up
Ниже ||| Move down
Дублировать ||| Duplicate
Как у экрана ||| Match display
Своё ||| Custom
Сцена ||| Scene
Размер макета ||| Canvas size
Соотношение сторон ||| Aspect ratio
Фон ||| Background
Адаптация к времени суток и погоде ||| Adapt to time of day and weather
Осадки по текущей погоде ||| Rain/snow from current weather
Выберите слой слева или кликните по нему в превью. Добавить слой — кнопка «+». ||| Select a layer on the left or click it in the preview. Add a layer with “+”.
Слой: %@ ||| Layer: %@
Видимый ||| Visible
Масштаб ||| Scale
Поворот ||| Rotation
Вращение, °/с ||| Spin, °/s
Прозрачность ||| Opacity
Параллакс (глубина) ||| Parallax (depth)
Наложение ||| Blending
Обычное ||| Normal
Сложение (свет) ||| Add (light)
Экран ||| Screen
Умножение ||| Multiply
Мягкие края ||| Soft edges
Изображение ||| Image
Файл ||| File
Заменить… ||| Replace…
Оттенок (умножение) ||| Tint (multiply)
Цвет ||| Color
Ширина ||| Width
Высота ||| Height
Размер шрифта ||| Font size
Насыщенность ||| Saturation
Тонкий ||| Thin
Лёгкий ||| Light
Обычный ||| Regular
Полужирный ||| Semibold
Жирный ||| Bold
Эффекты ||| Effects
Волны ||| Waves
Амплитуда ||| Amplitude
Частота ||| Frequency
Скорость ||| Speed
Вертикальные ||| Vertical
Свечение ||| Glow
Радиус ||| Radius
Интенсивность ||| Intensity
Цвет свечения ||| Glow color
Цветокоррекция ||| Color grading
Тон ||| Hue
Яркость ||| Brightness
Реакция на звук ||| Audio reaction
Пульсация ||| Pulse
Полоса ||| Band
Бас ||| Bass
Середина ||| Mids
Верха ||| Highs
Общий уровень ||| Overall level
Источник ||| Emitter
Сверху ||| Top
Снизу ||| Bottom
По всему экрану ||| Whole screen
Из точки X/Y ||| From point X/Y
Количество ||| Count
Размер от ||| Min size
Размер до ||| Max size
Направление ||| Direction
Разброс ||| Spread
Время жизни, с ||| Lifetime, s
Гравитация ||| Gravity
Покачивание ||| Wobble
Цвет 1 ||| Color 1
Цвет 2 ||| Color 2
Форма ||| Shape
Мягкая точка ||| Soft dot
Кольцо ||| Ring
Штрих (дождь) ||| Streak (rain)
Своя картинка ||| Custom image
Выбрать картинку… ||| Choose image…
Заменить картинку… ||| Replace image…
Разлетаются от курсора ||| Scatter from cursor
Реакция на бас ||| Bass reaction
Библиотека ||| Library
%@ обоев · двойной клик — применить ||| %@ wallpapers · double-click to apply
Все теги ||| All tags
Теги ||| Tags
Отпустите, чтобы добавить в библиотеку ||| Drop to add to the library
Библиотека пуста ||| Library is empty
Перетащите сюда видео, картинки, GIF, папки с веб-обоями, шейдеры .frag или пакеты .wallpkg ||| Drop videos, images, GIFs, web wallpaper folders, .frag shaders or .wallpkg packages here
Ничего не найдено ||| Nothing found
Попробуйте другой запрос или фильтр ||| Try another search or filter
Импортировать файлы или папки… ||| Import files or folders…
Импортировать пакет .wallpkg… ||| Import .wallpkg package…
Новый шейдер ||| New shader
Новая сцена… ||| New scene…
Добавить ||| Add
Все ||| All
Избранное ||| Favorites
Применить на экран ||| Apply to display
Убрать из избранного ||| Remove from favorites
В избранное ||| Add to favorites
Открыть в редакторе ||| Open in editor
Экспорт в .wallpkg… ||| Export to .wallpkg…
Экспортировано: %@ ||| Exported: %@
Ошибка экспорта: %@ ||| Export error: %@
Не удалось:  ||| Failed:
Добавлено: %@ ||| Added: %@
ДОБРО ПОЖАЛОВАТЬ ||| WELCOME
Рабочий стол, который живёт ||| A desktop that comes alive
LiveWall превращает обои в видео, интерактивные сцены, шейдеры и визуализаторы — прямо под иконками рабочего стола. ||| LiveWall turns your wallpaper into videos, interactive scenes, shaders and visualizers — right beneath your desktop icons.
ЛЮБЫЕ ОБОИ ||| ANY WALLPAPER
Шесть типов обоев ||| Six wallpaper types
Видео, веб-страницы, картинки и слайдшоу, GLSL-шейдеры в стиле Shadertoy и сцены из слоёв. Просто перетащите файл в библиотеку. ||| Videos, web pages, images and slideshows, Shadertoy-style GLSL shaders and layered scenes. Just drop a file into the library.
БИБЛИОТЕКА И STEAM ||| LIBRARY & STEAM
Ваша коллекция ||| Your collection
Теги, избранное, поиск и плейлисты по таймеру или времени суток. Импорт видео- и веб-обоев из мастерской Wallpaper Engine. ||| Tags, favorites, search and playlists by timer or time of day. Import video and web wallpapers from the Wallpaper Engine Workshop.
РЕДАКТОР СЦЕН ||| SCENE EDITOR
Создавайте своё ||| Make your own
Слои, параллакс от мыши, снег, искры и светлячки, волны и свечение, часы и дата. Перетаскивайте слои прямо в превью. ||| Layers, mouse parallax, snow, sparks and fireflies, waves and glow, clock and date. Drag layers right in the preview.
ЗВУК ||| SOUND
Обои слышат музыку ||| Wallpapers hear your music
Включите реакцию на звук — сцены, шейдеры и веб-обои будут пульсировать в такт тому, что играет на Mac. ||| Turn on audio reaction and scenes, shaders and web wallpapers will pulse to whatever is playing on your Mac.
ПРОИЗВОДИТЕЛЬНОСТЬ ||| PERFORMANCE
Умная пауза ||| Smart pause
Обои засыпают, когда приложение развёрнуто на весь экран, экран заблокирован или включена работа от батареи. FPS — под вашим контролем. ||| Wallpapers sleep when an app goes full screen, the screen is locked or you’re on battery. Frame rate is under your control.
ВСЁ ГОТОВО ||| ALL SET
Начнём? ||| Ready?
Пара настроек напоследок — их всегда можно поменять в разделе «Настройки». ||| A couple of settings to finish — you can always change them in Settings.
Пропустить ||| Skip
Назад ||| Back
Далее ||| Next
Начать ||| Start
Параллакс от мыши ||| Mouse parallax
Пауза от батареи ||| Pause on battery
Видео ||| Video
Веб ||| Web
Картинка ||| Image
Слайдшоу ||| Slideshow
Шейдер ||| Shader
Поводите мышью — это параллакс ||| Move your mouse — that’s parallax
ПАУЗА ||| PAUSED
ЖИВЫЕ ОБОИ ДЛЯ MAC ||| LIVE WALLPAPERS FOR MAC
Нажмите любую клавишу или кликните, чтобы пропустить ||| Press any key or click to skip
1. Что такое LiveWall ||| 1. What LiveWall is
LiveWall — приложение для macOS, которое показывает живые обои: видео, веб-страницы, GLSL-шейдеры, сцены и слайдшоу. Это личный некоммерческий проект, созданный для вашего компьютера. ||| LiveWall is a macOS app that shows live wallpapers: videos, web pages, GLSL shaders, scenes and slideshows. It is a personal, non-commercial project made for your computer.
2. Лицензия ||| 2. License
Вам предоставляется право бесплатно использовать, изменять и пересобирать LiveWall для личных целей. Исходный код принадлежит вам. ||| You may use, modify and rebuild LiveWall free of charge. The source code is available under the MIT license.
3. Чужой контент ||| 3. Third-party content
Обои, которые вы импортируете (видео, изображения, проекты из мастерской Wallpaper Engine), принадлежат их авторам. Используйте только контент, на который у вас есть права. Для обоев из мастерской Steam требуется купленная копия Wallpaper Engine; LiveWall не обходит никаких защит и не распространяет чужой контент. ||| Wallpapers you import (videos, images, Wallpaper Engine Workshop projects) belong to their authors. Only use content you have rights to. Steam Workshop wallpapers require a purchased copy of Wallpaper Engine; LiveWall does not bypass any protection or redistribute third-party content.
4. Steam и steamcmd ||| 4. Steam and steamcmd
Загрузка из мастерской выполняется официальной утилитой Valve steamcmd. Вход в Steam вы выполняете сами в Терминале — LiveWall не видит, не хранит и не передаёт ваш пароль или коды Steam Guard. Steam и steamcmd — товарные знаки Valve Corporation. ||| Workshop downloads use Valve’s official steamcmd tool. You sign in to Steam yourself in Terminal — LiveWall never sees, stores or transmits your password or Steam Guard codes. Steam and steamcmd are trademarks of Valve Corporation.
5. Конфиденциальность ||| 5. Privacy
LiveWall не собирает персональные данные. Разрешение «Запись экрана и системного звука» используется только для получения спектра звука; изображение экрана не записывается и не сохраняется. Приложение обращается к GitHub (галерея и проверка обновлений) и, если вы указали город, к Open-Meteo (погода) — туда уходят только название города и координаты. Все настройки и библиотека хранятся локально в ~/Library/Application Support/LiveWall. ||| LiveWall does not collect personal data. The “Screen & System Audio Recording” permission is used only to get the audio spectrum; the screen image is never recorded or stored. The app contacts GitHub (gallery and update checks) and, if you set a city, Open-Meteo (weather) — only the city name and coordinates are sent. All settings and the library are stored locally in ~/Library/Application Support/LiveWall.
6. Ресурсы и энергопотребление ||| 6. Resources and power use
Живые обои расходуют ресурсы процессора, видеокарты и батареи. Приложение умеет ставить обои на паузу, но вы сами отвечаете за выбор настроек производительности. ||| Live wallpapers use CPU, GPU and battery. The app can pause wallpapers, but you are responsible for choosing performance settings.
7. Отказ от гарантий ||| 7. No warranty
Программа предоставляется «как есть», без каких-либо гарантий. Авторы не несут ответственности за возможные сбои, потерю данных или иной ущерб, связанный с использованием программы. ||| The software is provided “as is”, without warranty of any kind. The authors are not liable for crashes, data loss or any other damage arising from its use.
8. Изменения ||| 8. Changes
Условия могут обновляться вместе с приложением. Продолжая использовать LiveWall после обновления, вы соглашаетесь с новой редакцией. ||| These terms may change with app updates. By continuing to use LiveWall after an update, you accept the new version.
Условия использования ||| Terms of Use
Пожалуйста, прочитайте до конца перед началом работы ||| Please read to the end before you start
Редакция от 24 ноября 2026 г. ||| Version of November 24, 2026
Я прочитал(а) и принимаю условия ||| I have read and accept the terms
Прокрутите условия до конца ||| Scroll to the end of the terms
Отклонить и выйти ||| Decline and quit
Принять ||| Accept
В главной роли ||| Starring
Идея и продюсирование ||| Idea and production
Движок рабочего стола ||| Desktop engine
AppKit · NSWindow на уровне рабочего стола ||| AppKit · desktop-level NSWindow
Рендеринг ||| Rendering
Звук ||| Audio
Интерфейс ||| Interface
Совместимость ||| Compatibility
API веб-обоев Wallpaper Engine ||| Wallpaper Engine web wallpaper API
Шейдеры в стиле Shadertoy ||| Shadertoy-style shaders
Мастерская ||| Workshop
Вдохновение ||| Inspiration
и все, кто делает рабочий стол живым ||| and everyone who brings desktops to life
Цветовая гамма ||| Color palette
Угольный · Алый ||| Charcoal · Crimson
Особая благодарность ||| Special thanks
Вам — за то, что досмотрели титры ||| To you — for watching the credits to the end
версия %@ ||| version %@
Сделано с любовью к красивым рабочим столам ||| Made with love for beautiful desktops
Сначала ||| Restart
Галерея ||| Gallery
Готовые сцены и шейдеры — установка в один клик ||| Ready-made scenes and shaders — one-click install
Обновить ||| Update
Сцены ||| Scenes
Шейдеры ||| Shaders
Загружаем каталог… ||| Loading catalog…
Нет соединения ||| No connection
Повторить ||| Retry
Применить ||| Apply
Установить ||| Install
Только добавить в библиотеку ||| Add to library only
Доступна версия %@ ||| Version %@ is available
Загрузка обновления… %@% ||| Downloading update… %@%
Установка и перезапуск… ||| Installing and relaunching…
Установлена версия %@ ||| Installed version %@
Проверить ||| Check
Проверять обновления автоматически ||| Check for updates automatically
Обновления ||| Updates
Новые версии приходят из релизов GitHub. Обновление скачивается, проверяется и устанавливается, приложение перезапускается само. ||| New versions come from GitHub releases. The update is downloaded, verified and installed, and the app relaunches by itself.
Ещё не проверялось ||| Not checked yet
Проверено ||| Checked
Проверка… ||| Checking…
У вас последняя версия ||| You’re up to date
Загрузка… %@% ||| Downloading… %@%
Установка… ||| Installing…
живые обои ||| live wallpapers
ОБОИ ||| WALLPAPERS
СОЗДАНИЕ ||| CREATE
ПРИЛОЖЕНИЕ ||| APP
НЕТ ОБОЕВ ||| NO WALLPAPER
НА ПАУЗЕ ||| PAUSED
СЕЙЧАС ||| NOW
Wallpaper Engine из Steam ||| Wallpaper Engine from Steam
Сканировать ||| Scan
Обои из мастерской Wallpaper Engine (нужен купленный Wallpaper Engine на вашем аккаунте Steam). Типы **video** и **web** переносятся как есть, вместе с настройками. Сцены (**scene**) конвертируются в сцены LiveWall: оригинальные картинки, слои, параллакс, частицы и похожие эффекты; анимация персонажей и шейдеры WE не переносятся. ||| Wallpapers from the Wallpaper Engine Workshop (requires Wallpaper Engine purchased on your Steam account). **video** and **web** types are imported as is, with their settings. Scenes (**scene**) are converted to LiveWall scenes: original images, layers, parallax, particles and similar effects; character animation and WE shaders are not carried over.
Папки мастерской ||| Workshop folders
не найдены ||| not found
Указать папку вручную… ||| Choose folder manually…
Импортировать все поддерживаемые ||| Import all supported
Показывать неподдерживаемые ||| Show unsupported
В библиотеке ||| In library
Импорт ||| Import
Не поддерживается ||| Not supported
Найдено в мастерской (%@) ||| Found in Workshop (%@)
Логин Steam ||| Steam login
Путь к steamcmd (необязательно) ||| Path to steamcmd (optional)
не найден ||| not found
ID или ссылка на предмет мастерской ||| Workshop item ID or link
Загрузка… ||| Loading…
Скачать ||| Download
Войти в steamcmd (откроется Терминал) ||| Sign in to steamcmd (opens Terminal)
Скачать через steamcmd ||| Download with steamcmd
1. Установите steamcmd: `brew install --cask steamcmd` (или вручную с сайта Valve). ||| 1. Install steamcmd: `brew install --cask steamcmd` (or manually from Valve’s site).
2. Укажите логин и нажмите «Войти в steamcmd» — в Терминале введите пароль и код Steam Guard. LiveWall пароль не видит и не хранит. ||| 2. Enter your login and click “Sign in to steamcmd” — type your password and Steam Guard code in Terminal. LiveWall never sees or stores your password.
3. Вставьте ссылку вида steamcommunity.com/sharedfiles/filedetails/?id=… и нажмите «Скачать». ||| 3. Paste a link like steamcommunity.com/sharedfiles/filedetails/?id=… and click “Download”.
Выключено ||| Off
Запуск… ||| Starting…
Работает ||| Running
Нет доступа: %@. Разрешите LiveWall в «Системные настройки → Конфиденциальность и безопасность → Запись экрана и системного звука», затем перезапустите приложение. ||| No access: %@. Allow LiveWall in System Settings → Privacy & Security → Screen & System Audio Recording, then relaunch the app.
LiveWall — живые обои ||| LiveWall — live wallpapers
Сейчас: %@ ||| Now: %@
Обои не выбраны ||| No wallpaper selected
Обновить до %@ ||| Update to %@
Продолжить ||| Resume
Пауза ||| Pause
Следующие обои ||| Next wallpaper
Плейлист ||| Playlist
✓ Без плейлиста ||| ✓ No playlist
Без плейлиста ||| No playlist
Открыть LiveWall… ||| Open LiveWall…
Выйти ||| Quit
в папке нет видео/картинок, index.html, scene.json или project.json ||| the folder has no videos/images, index.html, scene.json or project.json
неподдерживаемый формат .%@ ||| unsupported format .%@
в пакете нет manifest.json ||| the package has no manifest.json
Небо ||| Sky
Сияние ||| Aurora glow
Часы ||| Clock
Дата ||| Date
Ночные часы ||| Night clock
пример ||| sample
часы ||| clock
Волны (шейдер) ||| Waves (shader)
Аудио-визуализатор ||| Audio visualizer
звук ||| audio
Цвет полос ||| Bar color
Количество полос ||| Bar count
Отражение ||| Reflection
Заполнить ||| Fill
Вписать ||| Fit
Растянуть ||| Stretch
Скорость воспроизведения ||| Playback speed
Интервал (сек) ||| Interval (sec)
Длительность перехода (сек) ||| Transition duration (sec)
Качество (разрешение) ||| Quality (resolution)
Сила параллакса ||| Parallax strength
Скорость анимации ||| Animation speed
Команда завершилась с кодом %@ ||| Command exited with code %@
Снег ||| Snow
Дождь ||| Rain
Искры ||| Sparks
Пыль ||| Dust
Светлячки ||| Fireflies
Пузыри ||| Bubbles
Системный монитор ||| System monitor
Батарея ||| Battery
Сейчас играет ||| Now playing
Ближайшее событие ||| Next event
Погода ||| Weather
Ошибка загрузки: %@ ||| Loading error: %@
Каталог недоступен ||| Catalog unavailable
Не удалось загрузить галерею: %@ ||| Couldn’t load the gallery: %@
Файл недоступен ||| File unavailable
Установлено и применено: %@ ||| Installed and applied: %@
Добавлено в библиотеку: %@ ||| Added to library: %@
Ошибка установки: %@ ||| Install error: %@
GitHub не ответил ||| GitHub did not respond
Доступно обновление LiveWall %@ ||| LiveWall %@ is available
Не удалось скачать обновление ||| Couldn’t download the update
Контрольная сумма не совпала — обновление отменено ||| Checksum mismatch — update cancelled
В архиве нет подходящего LiveWall.app ||| The archive has no matching LiveWall.app
Обновление работает только для собранного LiveWall.app ||| Updates only work for the built LiveWall.app
Нет прав на запись в %@ ||| No write permission for %@
Нет дисплея для захвата звука ||| No display for audio capture
Ничего не играет ||| Nothing playing
Событий нет ||| No events
Доступ к календарю есть ||| Calendar access granted
Нет доступа. Разрешите LiveWall в «Конфиденциальность и безопасность → Календари». ||| No access. Allow LiveWall in Privacy & Security → Calendars.
Ясно ||| Clear
Малооблачно ||| Partly cloudy
Пасмурно ||| Overcast
Туман ||| Fog
Морось ||| Drizzle
Гроза ||| Thunderstorm
восход %@, закат %@ ||| sunrise %@, sunset %@
Город не указан — используется время по умолчанию (07:00–18:30) ||| No city set — using default times (07:00–18:30)
Поиск города… ||| Searching city…
Город не найден ||| City not found
Ошибка сети: %@ ||| Network error: %@
нет project.json ||| no project.json
тип «%@» не поддерживается (поддерживаются video и web; scene — закрытый формат) ||| type “%@” is not supported (video and web are; scene is a closed format)
Цвет схемы ||| Scheme color
Выравнивание ||| Alignment
Папка мастерской Wallpaper Engine не найдена. Укажите её вручную или скачайте предмет через steamcmd. ||| Wallpaper Engine Workshop folder not found. Choose it manually or download an item with steamcmd.
Найдено проектов: %@, поддерживается: %@ ||| Projects found: %@, supported: %@
Импортировано: %@ ||| Imported: %@
Не удалось распознать ID предмета ||| Couldn’t recognize the item ID
steamcmd не найден. Установите его (см. инструкцию ниже) или укажите путь. ||| steamcmd not found. Install it (see below) or set its path.
Укажите логин Steam ||| Enter your Steam login
Загрузка предмета %@… ||| Downloading item %@…
Не удалось запустить steamcmd: %@ ||| Couldn’t start steamcmd: %@
Не удалось скачать (код %@). Если steamcmd просит пароль — нажмите «Войти в steamcmd» и войдите один раз в Терминале. ||| Download failed (code %@). If steamcmd asks for a password, click “Sign in to steamcmd” and sign in once in Terminal.
Скачано «%@», но тип «%@» не поддерживается. ||| Downloaded “%@”, but type “%@” is not supported.
Скачано и добавлено в библиотеку: «%@» ||| Downloaded and added to library: “%@”
«%@» уже в библиотеке ||| “%@” is already in the library
steamcmd не найден ||| steamcmd not found
Не удалось открыть Терминал: %@ ||| Couldn’t open Terminal: %@
Плотность волн ||| Wave density
Полосы ||| Bands
Тёмный ||| Dark
Яркий ||| Bright
Скорость полёта ||| Flight speed
Оттенок ||| Tint
Цвет сетки ||| Grid color
Цвет солнца ||| Sun color
Горячий ||| Hot
Холодный ||| Cold
Капли ||| Blobs
Вода ||| Water
Волнение ||| Swell
Луна ||| Moon
Жар ||| Heat
Отблеск ||| Reflection
Туман ||| Fog
Свет ||| Light
Сумерки ||| Dusk
Фонари ||| Street lights
Событие ||| Event
Музыка ||| Music
Например, Москва или Baku ||| E.g. London or Baku
Введите название города ||| Enter a city name
Пауза, когда активна другая программа ||| Pause when another app is focused
Обои идут, только пока вы на рабочем столе (Finder) или в LiveWall ||| Wallpapers play only while you are on the desktop (Finder) or in LiveWall
Работает (системный звук) ||| Running (system audio)
macOS спросит разрешение «Только запись системного звука» (на macOS 14.2 и новее) — изображение экрана не захватывается, звук никуда не сохраняется. Спектр доступен веб-обоям (wallpaperRegisterAudioListener), шейдерам (iAudio, iSpectrum) и сценам. ||| macOS will ask for “System Audio Recording Only” (on macOS 14.2 and later) — the screen is never captured and audio is not saved anywhere. The spectrum is available to web wallpapers (wallpaperRegisterAudioListener), shaders (iAudio, iSpectrum) and scenes.
Нет разрешения «Запись экрана и системного звука». Нажмите «Выдать доступ», включите LiveWall в списке и перезапустите приложение. ||| No “Screen & System Audio Recording” permission. Click “Grant access”, enable LiveWall in the list and relaunch the app.
Выдать доступ ||| Grant access
Перезапустить LiveWall ||| Relaunch LiveWall
steamcmd установлен ||| steamcmd installed
Войдите один раз — пароль уходит только в официальный steamcmd и не сохраняется. ||| Sign in once — your password goes only to the official steamcmd and is never stored.
Войти ||| Sign in
Войти в Steam ||| Sign in to Steam
Всё синхронизировано — новых подписок нет ||| All synced — no new subscriptions
Вход в Steam ||| Steam sign-in
Вход в Steam не выполнен ||| Not signed in to Steam
Вход выполнен ||| Signed in
Вход выполнен: %@ ||| Signed in: %@
Вход на steamcommunity.com ||| Sign in to steamcommunity.com
Вход не выполнен (код %@) ||| Sign-in failed (code %@)
steamcmd нужна Rosetta 2. Выполните в Терминале: softwareupdate --install-rosetta --agree-to-license ||| steamcmd needs Rosetta 2. Run in Terminal: softwareupdate --install-rosetta --agree-to-license
Готово: добавлено %@ ||| Done: %@ added
Добавлено из мастерской: %@ ||| Added from Workshop: %@
Имя аккаунта Steam (не e-mail) ||| Steam account name (not e-mail)
Код Steam Guard из приложения ||| Steam Guard code from the app
Код из письма Steam ||| Code from Steam e-mail
Конвертируем и добавляем в библиотеку… ||| Converting and adding to the library…
Не удалось скачать steamcmd ||| Couldn’t download steamcmd
Неверный логин или пароль ||| Wrong login or password
Новых подписок нет ||| No new subscriptions
Нужен steamcmd ||| steamcmd required
Нужен аккаунт, на котором куплен Wallpaper Engine ||| Use the account that owns Wallpaper Engine
Нужен один раз, чтобы видеть ваши подписки. Можно войти по QR-коду из Steam Mobile. ||| Needed once to see your subscriptions. You can sign in with a QR code from Steam Mobile.
Официальная утилита Valve для загрузки из мастерской. Установится в папку LiveWall. ||| Valve’s official tool for Workshop downloads. It installs into the LiveWall folder.
Пароль ||| Password
Пароль передаётся только официальной утилите Valve steamcmd и нигде не сохраняется. Вход запоминает сам steamcmd. ||| Your password is passed only to Valve’s official steamcmd and is never stored. steamcmd remembers the sign-in itself.
Подтвердите вход в приложении Steam Mobile на телефоне ||| Confirm the sign-in in the Steam Mobile app on your phone
Подтвердить ||| Confirm
Получаем список подписок… ||| Fetching your subscriptions…
Проверяем вход… ||| Checking sign-in…
Синхронизация скачает новые подписки Wallpaper Engine и добавит их в плейлист. ||| Sync downloads new Wallpaper Engine subscriptions and adds them to the playlist.
Синхронизировать мастерскую ||| Sync Workshop
Скачиваем: %@ из %@ ||| Downloading: %@ of %@
Слишком много попыток. Подождите немного. ||| Too many attempts. Please wait a bit.
Сначала установите steamcmd ||| Install steamcmd first
Устанавливаем steamcmd… ||| Installing steamcmd…
мало данных текстуры ||| texture data too short
не PKG-архив (%@) ||| not a PKG archive (%@)
не TEX (%@) ||| not a TEX file (%@)
не удалось записать GIF ||| couldn’t write GIF
не удалось собрать изображение ||| couldn’t build image
не удалось создать GIF ||| couldn’t create GIF
неизвестный формат текстуры %@ ||| unknown texture format %@
неожиданный конец файла ||| unexpected end of file
нет mip-уровней ||| no mip levels
нет блока TEXB ||| no TEXB block
повреждённая строка ||| corrupted string
повреждённые данные LZ4 ||| corrupted LZ4 data
пустая текстура ||| empty texture
тип «%@» не поддерживается ||| type “%@” is not supported
в сцене нет scene.json ||| the scene has no scene.json
звук «%@» пропущен ||| sound “%@” skipped
нет модели %@ ||| missing model %@
анимация персонажа в «%@» не переносится ||| character animation in “%@” is not carried over
нет материала у «%@» ||| “%@” has no material
встроенная текстура «%@» недоступна ||| built-in texture “%@” is unavailable
текстура «%@»: %@ ||| texture “%@”: %@
анимированный слой «%@» сохранён как GIF ||| animated layer “%@” saved as GIF
в сцене не нашлось слоёв, которые можно перенести ||| the scene has no layers that can be converted
эффект «%@» не переносится ||| effect “%@” is not carried over
Нет поддерживаемых обоев для импорта ||| No supported wallpapers to import
Импортировано и добавлено в плейлист: %@ ||| Imported and added to playlist: %@
Импортировать всё и создать плейлист ||| Import all and create a playlist
Удалить выбранные обои (%@)? ||| Delete the selected wallpapers (%@)?
Файлы обоев из библиотеки будут перемещены в Корзину. ||| Library wallpaper files will be moved to the Trash.
Удалено: %@ ||| Deleted: %@
Выбрано: %@ ||| Selected: %@
Выбрать все ||| Select all
Снять выбор ||| Clear selection
Снег ||| Snow
Снег на рабочем столе ||| Desktop snow
Снежинки падают поверх рабочего стола и оседают на окнах ||| Snowflakes fall over your desktop and settle on windows
Включить снег ||| Enable snow
Внешний вид ||| Appearance
Количество снега ||| Amount of snow
Размер снежинок ||| Flake size
Поведение ||| Behavior
Оседает на верхних краях окон ||| Settles on top edges of windows
Курсор отталкивает снег и сметает сугробы ||| Cursor pushes snow away and sweeps drifts
Гирлянды под строкой меню ||| String lights under the menu bar
Очистить сугробы ||| Clear drifts
Паузы: обои и снег настраиваются отдельно ||| Pauses: wallpaper and snow are set separately
Обои ||| Wallpaper
При работе от батареи ||| On battery power
Когда приложение открыто на весь экран ||| When an app is full screen
При блокировке экрана и сне дисплея ||| On screen lock and display sleep
Когда окно развёрнуто почти на весь экран ||| When a window is nearly full screen
Снег поверх окон не перехватывает клики: рабочий стол и окна остаются доступными. ||| Snow does not intercept clicks: your desktop and windows stay usable.
Stage Manager включён: macOS не сообщает настоящее положение окон, поэтому снег на окнах отключён. Выключите Stage Manager в Пункте управления, чтобы вернуть сугробы. ||| Stage Manager is on: macOS does not report the real window positions, so snow on windows is disabled. Turn Stage Manager off in Control Center to get drifts back.
включено «Уменьшить движение» в Универсальном доступе ||| Reduce Motion is on in Accessibility
Mac работает от батареи ||| your Mac is on battery
экран заблокирован ||| the screen is locked
открыто полноэкранное приложение ||| a full-screen app is open
окно развёрнуто почти на весь экран ||| a window is nearly full screen
Снег сейчас на паузе: %@. Это можно изменить в разделе «Паузы» ниже. ||| Snow is paused right now: %@. You can change this under Pauses below.
При включённом «Уменьшить движение» ||| When Reduce Motion is on
Обои несколько раз перестали отрисовываться (%@) и были остановлены. Выберите их снова, чтобы перезапустить. ||| This wallpaper stopped rendering several times (%@) and was halted. Choose it again to restart it.
Те же обои на экране блокировки ||| Same wallpaper on the lock screen
LiveWall ставит стоп-кадр текущих обоев системной картинкой рабочего стола — её macOS показывает на экране блокировки ||| LiveWall sets a still frame of the current wallpaper as the system desktop picture, which macOS shows on the lock screen
Умный FPS ||| Smart FPS
В покое обои рисуются не чаще 20 кадров/с, а при движении мыши и на ударах в музыке — до выбранного лимита ||| When idle, wallpapers draw at most 20 fps; on mouse movement and music beats they go up to the chosen limit
Сцены на Metal (быстрее) ||| Scenes on Metal (faster)
Сцены рисуются напрямую на видеокарте, без веб-движка. Выключите, если какая-то сцена выглядит не так, как раньше ||| Scenes are drawn directly on the GPU, without the web engine. Turn this off if a scene looks different than before
Не удалось загрузить %@ ||| Couldn’t load %@
с Новым годом! ||| happy holidays!
Оформление ||| Appearance
Новогоднее оформление ||| Holiday theme
Алый и белый, как леденец, мерцающие гирлянды и украшения ||| Candy-cane red and white, twinkling garlands and ornaments
Экран блокировки ||| Lock screen
LiveWall ставит стоп-кадр текущих обоев системной картинкой рабочего стола — её macOS показывает на экране блокировки. Если выключить, вернётся картинка, которая стояла до LiveWall. ||| LiveWall sets a still frame of the current wallpaper as the system desktop picture, which macOS shows on the lock screen. Turn it off to get back the picture you had before LiveWall.
Обои на экране блокировки ||| Wallpaper on lock screen
"""#
}
