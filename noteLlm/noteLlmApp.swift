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
    @EnvironmentObject var aiViewModel: AIViewModel

    var body: some View {
        ContentView()
            .task(id: appState.selectedModelSize) {
                let modelID = appState.selectedModelSize.rawValue
                appState.modelLoadingState = .downloading(progress: 0)
                aiViewModel.ensureModelLoaded(
                    modelID: modelID,
                    progressHandler: { progress in
                        Task { @MainActor in
                            appState.modelLoadingState = progress >= 1 ? .loaded : .downloading(progress: progress)
                        }
                    },
                    failureHandler: { message in
                        Task { @MainActor in
                            appState.modelLoadingState = .failed(message)
                        }
                    }
                )
            }
    }
}
