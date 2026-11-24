import SwiftUI

/// Вкладка «Снег»: снег поверх рабочего стола, сугробы на окнах, гирлянды и отдельные паузы.
struct SnowView: View {
    @EnvironmentObject var app: AppState

    private func b<T>(_ kp: WritableKeyPath<AppSettings, T>) -> Binding<T> {
        Binding(get: { app.settings[keyPath: kp] }, set: { app.settings[keyPath: kp] = $0 })
    }

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(title: tr("Снег"), subtitle: tr("Снежинки падают поверх рабочего стола и оседают на окнах"))
            Form {
                Section {
                    Toggle(tr("Включить снег"), isOn: b(\.snowEnabled))
                    Text(tr("Снег поверх окон не перехватывает клики: рабочий стол и окна остаются доступными."))
                        .font(.caption).foregroundStyle(.secondary)
                }

                Section(tr("Внешний вид")) {
                    SliderRow(title: tr("Количество снега"), value: b(\.snowDensity), range: 0.1...1, format: "%.2f")
                    SliderRow(title: tr("Размер снежинок"), value: b(\.snowSize), range: 0.5...2, format: "%.2f")
                }
                .disabled(!app.settings.snowEnabled)

                Section(tr("Поведение")) {
                    Toggle(tr("Оседает на верхних краях окон"), isOn: b(\.snowOnWindows))
                    Toggle(tr("Курсор отталкивает снег и сметает сугробы"), isOn: b(\.snowCursor))
                    Toggle(tr("Гирлянды под строкой меню"), isOn: b(\.snowGarlands))
                    if SnowController.stageManagerOn {
                        Label(tr("Stage Manager включён: macOS не сообщает настоящее положение окон, поэтому снег на окнах отключён. Выключите Stage Manager в Пункте управления, чтобы вернуть сугробы."), systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(.orange)
                    }
                    Button(tr("Очистить сугробы")) { app.snow.clearSnow() }
                        .buttonStyle(GhostButtonStyle(compact: true))
                }
                .disabled(!app.settings.snowEnabled)

                Section(tr("Паузы: обои и снег настраиваются отдельно")) {
                    pauseGrid
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .toggleStyle(CrimsonToggleStyle())
        }
    }

    private var pauseGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(tr("Обои")).font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.scarlet)
            Toggle(tr("При работе от батареи"), isOn: b(\.pauseOnBattery))
            Toggle(tr("Когда приложение открыто на весь экран"), isOn: b(\.pauseOnFullscreen))
            Toggle(tr("Когда окно развёрнуто почти на весь экран"), isOn: b(\.pauseOnMaximized))
            Toggle(tr("При блокировке экрана и сне дисплея"), isOn: b(\.pauseOnLock))
            Divider().padding(.vertical, 4)
            Text(tr("Снег")).font(.system(size: 12, weight: .bold)).foregroundStyle(Theme.scarlet)
            Toggle(tr("При работе от батареи"), isOn: b(\.snowPauseOnBattery))
            Toggle(tr("Когда приложение открыто на весь экран"), isOn: b(\.snowPauseOnFullscreen))
            Toggle(tr("Когда окно развёрнуто почти на весь экран"), isOn: b(\.snowPauseOnMaximized))
            Toggle(tr("При блокировке экрана и сне дисплея"), isOn: b(\.snowPauseOnLock))
        }
    }
}
