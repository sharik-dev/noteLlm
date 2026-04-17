import Foundation
import NaturalLanguage

enum PromptBuilder {
    static let systemPrompt = """
    You are a warm, thoughtful journaling companion. When someone shares their daily note with you:

    1. Read it carefully and acknowledge what they've shared
    2. Ask exactly 3 open-ended questions that help them explore their thoughts, feelings, or next steps
    3. Each question must end with "?" and appear on its own line

    Rules:
    - Be concise — total response under 120 words
    - Avoid generic questions; anchor each question to specific details in their note
    - No preamble like "Great entry!" — dive straight into reflection
    - Format: one short observation sentence, then the 3 questions on separate lines
    - Always reply in the user's dominant writing language for this note
    - Plain text only
    - Do not use markdown
    - Do not use asterisks, bold markers, bullet points, or dashes as list prefixes
    """

    static func build(noteContent: String, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: date)

        let trimmed = noteContent.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = trimmed.isEmpty ? "(no content yet)" : trimmed
        let languageContext = LanguageContext.from(text: trimmed)

        return """
        Today is \(dateStr).

        Dominant writing language: \(languageContext.name) (\(languageContext.percent)% confidence).
        Reply in \(languageContext.name). If the note mixes languages, follow the dominant one.

        Journal entry:
        \(body)
        """
    }
}

private struct LanguageContext {
    let name: String
    let percent: Int

    static func from(text: String) -> Self {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .init(name: "the same language as the user", percent: 100)
        }

        let recognizer = NLLanguageRecognizer()
        recognizer.processString(trimmed)

        if let (language, confidence) = recognizer.languageHypotheses(withMaximum: 1).max(by: { $0.value < $1.value }) {
            let locale = Locale.current
            let rawName = locale.localizedString(forIdentifier: language.rawValue)
                ?? locale.localizedString(forLanguageCode: language.rawValue)
                ?? language.rawValue
            let normalizedName = rawName.prefix(1).uppercased() + rawName.dropFirst()
            return .init(
                name: normalizedName,
                percent: max(1, Int((confidence * 100).rounded()))
            )
        }

        return .init(name: "the same language as the user", percent: 100)
    }
}
