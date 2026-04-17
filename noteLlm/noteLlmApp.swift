import SwiftUI
import SwiftData

@main
struct DailyNoteApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var aiViewModel = AIViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(aiViewModel)
        }
        .modelContainer(for: Note.self)
    }
}

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        switch appState.modelLoadingState {
        case .notLoaded, .downloading:
            ModelDownloadView()
        case .loaded:
            ContentView()
        case .failed(let msg):
            VStack(spacing: 16) {
                Text("Model failed to load")
                    .font(.headline)
                Text(msg)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Retry") {
                    appState.modelLoadingState = .notLoaded
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}
