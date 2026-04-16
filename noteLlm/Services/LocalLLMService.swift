import Foundation
import LocalLLMClient
import LocalLLMClientMLX

final class LocalLLMService: LLMServiceProtocol {
    private var client: (any LLMClientProtocol)?
    private(set) var isModelReady = false

    func loadModel(modelID: String, progressHandler: @escaping (Double) -> Void) async throws {
        let downloader = FileDownloader(source: .huggingFace(id: modelID, globs: nil))

        if FileManager.default.fileExists(atPath: downloader.destination.path) {
            // Model already cached — skip download
            progressHandler(1.0)
        } else {
            try await downloader.download { progress in
                progressHandler(progress)
            }
        }

        client = try await LocalLLMClient.mlx(configuration: .init(modelPath: downloader.destination.path))
        isModelReady = true
    }

    func stream(prompt: String) -> AsyncStream<String> {
        AsyncStream { continuation in
            guard let client else {
                continuation.finish()
                return
            }
            let input = LLMInput.chat(messages: [
                .system(PromptBuilder.systemPrompt),
                .user(prompt)
            ])
            Task {
                do {
                    let tokenStream = try await client.textStream(input: input)
                    for try await token in tokenStream {
                        continuation.yield(token)
                    }
                } catch {
                    // stream ends on error — caller observes incomplete output
                }
                continuation.finish()
            }
        }
    }

}
