import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("AI Model") {
                    Picker("Model Size", selection: $appState.selectedModelSize) {
                        ForEach(AppState.ModelSize.allCases) { size in
                            Text(size.displayName).tag(size)
                        }
                    }
                    .pickerStyle(.inline)

                    Text("Changing the model requires restarting the app to re-download.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Behavior") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Idle Delay")
                            Spacer()
                            Text("\(Int(appState.idleDelay))s")
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }
                        Slider(value: $appState.idleDelay, in: 3...10, step: 1)
                            .tint(.orange)
                    }
                    .padding(.vertical, 4)

                    Text("How long after you stop typing before the AI responds.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    LabeledContent("App", value: "DailyNote")
                    LabeledContent("Model Backend", value: "MLX (on-device)")
                    LabeledContent("Privacy", value: "All data stays on device")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
