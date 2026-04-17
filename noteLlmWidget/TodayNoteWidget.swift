import WidgetKit
import SwiftUI

private enum WidgetStore {
    static let appGroupID = "group.com.dailynote.app"
    static let noteKey = "widget_today_note"
    static let dateKey = "widget_today_date"
}

struct TodayNoteEntry: TimelineEntry {
    let date: Date
    let noteDate: String
    let noteText: String
}

struct TodayNoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayNoteEntry {
        TodayNoteEntry(
            date: .now,
            noteDate: "Today",
            noteText: "Your note for today will appear here."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayNoteEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayNoteEntry>) -> Void) {
        let entry = loadEntry()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func loadEntry() -> TodayNoteEntry {
        let defaults = UserDefaults(suiteName: WidgetStore.appGroupID)
        let noteDate = defaults?.string(forKey: WidgetStore.dateKey) ?? "Today"
        let rawText = defaults?.string(forKey: WidgetStore.noteKey)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let noteText = rawText.isEmpty ? "Nothing written yet today." : rawText

        return TodayNoteEntry(
            date: .now,
            noteDate: noteDate,
            noteText: noteText
        )
    }
}

struct TodayNoteWidgetEntryView: View {
    var entry: TodayNoteProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.noteDate)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(entry.noteText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct TodayNoteWidget: Widget {
    let kind: String = "TodayNoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayNoteProvider()) { entry in
            TodayNoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Note")
        .description("Shows what you wrote on today's journal page.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct TodayNoteWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayNoteWidget()
    }
}
