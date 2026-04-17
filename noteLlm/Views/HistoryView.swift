import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Note.date, order: .reverse) private var notes: [Note]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    Button {
                        appState.selectedDate = note.date
                        dismiss()
                    } label: {
                        NoteRowView(note: note, isToday: Calendar.current.isDateInToday(note.date))
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Past Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct NoteRowView: View {
    let note: Note
    let isToday: Bool

    private var dateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: note.date)
    }

    private var preview: String {
        let trimmed = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "No content" }
        return String(trimmed.prefix(120))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(dateLabel)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if isToday {
                    Text("Today")
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.green))
                }
                Spacer()
                Text("\(note.content.count) chars")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Text(preview)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}
