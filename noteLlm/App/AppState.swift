import SwiftUI
import Combine

enum ModelLoadingState: Equatable {
    case notLoaded
    case downloading(progress: Double)
    case loaded
    case failed(String)

    static func == (lhs: ModelLoadingState, rhs: ModelLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.notLoaded, .notLoaded), (.loaded, .loaded): return true
        case (.downloading(let a), .downloading(let b)): return a == b
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var modelLoadingState: ModelLoadingState = .notLoaded
    @Published var idleDelay: Double = 3.0
    @Published var selectedModelSize: ModelSize = .small

    enum ModelSize: String, CaseIterable, Identifiable {
        case tiny  = "mlx-community/Qwen2.5-0.5B-Instruct-4bit"
        case small = "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
        case medium = "mlx-community/Qwen2.5-3B-Instruct-4bit"

        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .tiny:   return "0.5B (Fast)"
            case .small:  return "1.5B (Balanced)"
            case .medium: return "3B (Quality)"
            }
        }
    }
}
