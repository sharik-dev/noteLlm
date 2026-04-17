import SwiftUI

struct AIPanelView: View {
    @EnvironmentObject var aiViewModel: AIViewModel
    @State private var dotPulse = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                statusDot
                Text("AI Companion")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    if aiViewModel.aiOutput.isEmpty && !aiViewModel.isThinking {
                        Text("Start writing — your AI companion will reflect with you after a pause.")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                            .italic()
                    } else {
                        Text(aiViewModel.aiOutput)
                            .font(.footnote)
                            .foregroundStyle(.primary)
                            .lineSpacing(4)
                            .lineLimit(nil)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.easeInOut(duration: 0.1), value: aiViewModel.aiOutput)
                    }

                    if !aiViewModel.suggestionChips.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(aiViewModel.suggestionChips, id: \.self) { chip in
                                ChipView(text: chip)
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var statusDot: some View {
        if aiViewModel.isThinking {
            Circle()
                .fill(Color.orange)
                .frame(width: 8, height: 8)
                .scaleEffect(dotPulse ? 1.4 : 1.0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: dotPulse)
                .onAppear { dotPulse = true }
                .onDisappear { dotPulse = false }
        } else if !aiViewModel.aiOutput.isEmpty {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
        } else {
            Circle()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 8, height: 8)
        }
    }
}

struct ChipView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
    }
}
