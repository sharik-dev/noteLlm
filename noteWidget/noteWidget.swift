import WidgetKit
import SwiftUI

private let appGroupID = "group.noteLlm"
private let noteKey   = "widget_today_note"
private let dateKey   = "widget_today_date"

struct NoteEntry: TimelineEntry {
    let date: Date
    let noteDate: String
    let noteText: String
}

struct NoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: .now, noteDate: "Aujourd'hui", noteText: "Votre note du jour apparaîtra ici.")
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
        let entry = loadEntry()
        let refresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func loadEntry() -> NoteEntry {
        let defaults = UserDefaults(suiteName: appGroupID)
        let noteDate = defaults?.string(forKey: dateKey) ?? "Aujourd'hui"
        let raw = defaults?.string(forKey: noteKey)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let noteText = raw.isEmpty ? "Rien d'écrit pour aujourd'hui." : raw
        return NoteEntry(date: .now, noteDate: noteDate, noteText: noteText)
    }
}

struct noteWidgetEntryView: View {
    var entry: NoteProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.noteDate)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(entry.noteText)
                .font(.system(size: family == .systemSmall ? 13 : 15, weight: .regular, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(family == .systemSmall ? 6 : 12)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(family == .systemSmall ? 4 : 8)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct noteWidget: Widget {
    let kind: String = "noteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NoteProvider()) { entry in
            noteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Note du jour")
        .description("Affiche ce que vous avez écrit aujourd'hui.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemMedium) {
    noteWidget()
} timeline: {
    NoteEntry(date: .now, noteDate: "17 avr. 2026", noteText: "Idée du matin : retravailler l'architecture des services pour mieux séparer la logique métier de la persistance.")
}
