import Foundation

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
    """

    static func build(noteContent: String, date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let dateStr = formatter.string(from: date)

        let trimmed = noteContent.trimmingCharacters(in: .whitespacesAndNewlines)
        let body = trimmed.isEmpty ? "(no content yet)" : trimmed

        return """
        Today is \(dateStr).

        Journal entry:
        \(body)
        """
    }
}
