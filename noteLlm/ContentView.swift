import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showHistory = false
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            AIPanelView()
            Divider()
                .padding(.top, 8)
            NoteEditorView()
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showHistory) {
            HistoryView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var toolbar: some View {
        HStack {
            Button {
                showHistory = true
            } label: {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundStyle(.secondary)

            Spacer()

            Text("DailyNote")
                .font(.headline)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
