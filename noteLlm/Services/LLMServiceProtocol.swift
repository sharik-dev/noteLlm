import Foundation

protocol LLMServiceProtocol: AnyObject {
    var isModelReady: Bool { get }
    func stream(prompt: String) -> AsyncStream<String>
    func loadModel(modelID: String, progressHandler: @escaping (Double) -> Void) async throws
}
