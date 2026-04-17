import SwiftUI
import Combine

@MainActor
final class AIViewModel: ObservableObject {
    @Published var aiOutput: String = ""
    @Published var isThinking: Bool = false
    @Published var suggestionChips: [String] = []

    var llmService: LLMServiceProtocol?

    private var streamTask: Task<Void, Never>?
    private var modelLoadTask: Task<Void, Never>?
    private var activeModelID: String?

    func ensureModelLoaded(
        modelID: String,
        progressHandler: @escaping (Double) -> Void = { _ in },
        failureHandler: @escaping (String) -> Void = { _ in }
    ) {
        if activeModelID == modelID, llmService?.isModelReady == true {
            progressHandler(1.0)
            return
        }

        if activeModelID != modelID || llmService == nil {
            llmService = LocalLLMService()
            activeModelID = modelID
        }

        guard let service = llmService, !service.isModelReady else {
            progressHandler(1.0)
            return
        }

        modelLoadTask?.cancel()
        modelLoadTask = Task {
            do {
                try await service.loadModel(modelID: modelID, progressHandler: progressHandler)
            } catch is CancellationError {
            } catch {
                failureHandler(error.localizedDescription)
            }
        }
    }

    func generateSuggestions(for text: String, date: Date = Date()) {
        guard let service = llmService, service.isModelReady else { return }

        streamTask?.cancel()
        aiOutput = ""
        isThinking = true

        let prompt = PromptBuilder.build(noteContent: text, date: date)
        let tokenStream = service.stream(prompt: prompt)

        streamTask = Task {
            var accumulated = ""
            for await token in tokenStream {
                guard !Task.isCancelled else { break }
                accumulated += token
                aiOutput = sanitizeModelOutput(accumulated)
            }
            isThinking = false
            let cleanedOutput = sanitizeModelOutput(accumulated)
            let questions = extractQuestions(from: cleanedOutput)
            suggestionChips = questions
            aiOutput = questions.isEmpty ? cleanedOutput : ""
        }
    }

    func cancelStream() {
        streamTask?.cancel()
        isThinking = false
    }

    private func extractQuestions(from text: String) -> [String] {
        let lines = text.components(separatedBy: "\n")
        let questions = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.hasSuffix("?") && $0.count > 10 }
        return Array(questions.suffix(3))
    }

    private func sanitizeModelOutput(_ text: String) -> String {
        text
            .components(separatedBy: .newlines)
            .map(sanitizeLine)
            .joined(separator: "\n")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "*", with: "")
    }

    private func sanitizeLine(_ line: String) -> String {
        var result = line.trimmingCharacters(in: .whitespaces)

        if result.hasPrefix("- ") {
            result.removeFirst(2)
        } else if result.hasPrefix("* ") {
            result.removeFirst(2)
        } else if result.hasPrefix("• ") {
            result.removeFirst(2)
        }

        return result
    }
}
