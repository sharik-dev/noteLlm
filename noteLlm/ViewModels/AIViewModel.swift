import SwiftUI
import Combine

@MainActor
final class AIViewModel: ObservableObject {
    @Published var aiOutput: String = ""
    @Published var isThinking: Bool = false
    @Published var suggestionChips: [String] = []

    var llmService: LLMServiceProtocol?

    private var streamTask: Task<Void, Never>?

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
                aiOutput = accumulated
            }
            isThinking = false
            suggestionChips = extractQuestions(from: accumulated)
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
}
