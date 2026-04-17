import SwiftUI
import Combine
import SwiftData
import WidgetKit

@MainActor
final class NoteViewModel: ObservableObject {
    @Published var noteText: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let aiViewModel: AIViewModel
    private let noteService: NoteService
    private let modelContext: ModelContext
    private var currentNote: Note?
    private var selectedDate: Date

    init(
        aiViewModel: AIViewModel,
        noteService: NoteService,
        modelContext: ModelContext,
        date: Date = Date()
    ) {
        self.aiViewModel = aiViewModel
        self.noteService = noteService
        self.modelContext = modelContext
        self.selectedDate = date

        loadNote(for: date)
        setupDebounce(delay: 3)
    }

    func loadNote(for date: Date) {
        selectedDate = date
        currentNote = noteService.fetchOrCreate(for: date, in: modelContext)
        noteText = currentNote?.content ?? ""
    }

    func updateDelay(_ seconds: Double) {
        cancellables.removeAll()
        setupDebounce(delay: seconds)
    }

    private func setupDebounce(delay: Double) {
        $noteText
            .dropFirst()
            .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.handleTextChange(text)
            }
            .store(in: &cancellables)

        $noteText
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.persistNote()
            }
            .store(in: &cancellables)
    }

    private func handleTextChange(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        Task {
            await aiViewModel.generateSuggestions(for: text, date: selectedDate)
        }
    }

    private func persistNote() {
        guard let note = currentNote else { return }
        note.content = noteText
        noteService.save(note: note, in: modelContext)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
