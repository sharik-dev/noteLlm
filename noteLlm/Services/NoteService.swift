import Foundation
import SwiftData

final class NoteService {
    private let appGroupID: String

    init(appGroupID: String = "group.com.dailynote.app") {
        self.appGroupID = appGroupID
    }

    func fetchOrCreate(for date: Date, in context: ModelContext) -> Note {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<Note>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let note = Note(date: startOfDay)
        context.insert(note)
        return note
    }

    func save(note: Note, in context: ModelContext) {
        note.content = note.content  // mark dirty
        try? context.save()
        syncToWidget(content: note.content, date: note.date)
    }

    func fetchAll(in context: ModelContext) -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private func syncToWidget(content: String, date: Date) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let preview = String(content.prefix(500))
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        defaults.set(preview, forKey: "widget_today_note")
        defaults.set(formatter.string(from: date), forKey: "widget_today_date")
    }
}
