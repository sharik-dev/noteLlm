import SwiftUI
import SwiftData

struct NoteEditorView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var aiViewModel: AIViewModel
    @Environment(\.modelContext) var modelContext
    @State private var viewModel: NoteViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                EditorContent(viewModel: vm)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                let service = NoteService()
                viewModel = NoteViewModel(
                    aiViewModel: aiViewModel,
                    noteService: service,
                    modelContext: modelContext,
                    date: appState.selectedDate
                )
            }
        }
        .onChange(of: appState.selectedDate) { _, newDate in
            viewModel?.loadNote(for: newDate)
        }
        .onChange(of: appState.idleDelay) { _, newDelay in
            viewModel?.updateDelay(newDelay)
        }
    }
}

private struct EditorContent: View {
    @ObservedObject var viewModel: NoteViewModel
    @EnvironmentObject var appState: AppState

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: appState.selectedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(dateString)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            TextEditor(text: $viewModel.noteText)
                .font(.body)
                .lineSpacing(6)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .topLeading) {
                    if viewModel.noteText.isEmpty {
                        Text("What's on your mind today?")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                }
        }
    }
}
