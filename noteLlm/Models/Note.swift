import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var date: Date
    var content: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = Calendar.current.startOfDay(for: Date()),
        content: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.createdAt = createdAt
    }
}
