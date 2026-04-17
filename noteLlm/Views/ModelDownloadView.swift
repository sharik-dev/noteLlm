import SwiftUI

struct ModelDownloadView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiViewModel: AIViewModel
    @State private var hasStarted = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 56))
                    .foregroundStyle(.orange)

                Text("DailyNote")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Your private AI journaling companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                switch appState.modelLoadingState {
                case .notLoaded:
                    VStack(spacing: 8) {
                        Text("The AI model (\(appState.selectedModelSize.displayName)) needs to be downloaded once.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Text("~800 MB · Wi-Fi recommended")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Button("Download & Continue") {
                        startDownload()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)

                case .downloading(let progress):
                    VStack(spacing: 8) {
                        ProgressView(value: progress)
                            .tint(.orange)
                            .padding(.horizontal)
                        Text("Downloading… \(Int(progress * 100))%")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                        Text("This only happens once.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                case .loaded:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.largeTitle)

                case .failed(let msg):
                    VStack(spacing: 8) {
                        Text("Download failed")
                            .foregroundStyle(.red)
                        Text(msg)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Button("Retry") { startDownload() }
                            .buttonStyle(.bordered)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            if case .notLoaded = appState.modelLoadingState, !hasStarted { }
        }
    }

    private func startDownload() {
        hasStarted = true
        let llmService = LocalLLMService()
        aiViewModel.llmService = llmService
        let modelID = appState.selectedModelSize.rawValue

        Task {
            appState.modelLoadingState = .downloading(progress: 0)
            do {
                try await llmService.loadModel(modelID: modelID) { progress in
                    Task { @MainActor in
                        appState.modelLoadingState = .downloading(progress: progress)
                    }
                }
                appState.modelLoadingState = .loaded
            } catch {
                appState.modelLoadingState = .failed(error.localizedDescription)
            }
        }
    }
}
