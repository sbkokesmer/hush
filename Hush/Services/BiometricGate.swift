import Foundation
import LocalAuthentication

@MainActor
final class BiometricGate: ObservableObject {
    @Published var isUnlocked = false
    @Published var lastError: String?
    private var inFlight = false

    func unlock(reason: String = "Unlock Hush") async {
        guard !inFlight, !isUnlocked else { return }
        inFlight = true
        defer { inFlight = false }

        let context = LAContext()
        context.localizedFallbackTitle = "Use Passcode"

        var error: NSError?
        let canEvaluate = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        guard canEvaluate else {
            lastError = error?.localizedDescription ?? "Biometric authentication not available"
            isUnlocked = true
            return
        }

        do {
            let ok = try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
            if ok {
                isUnlocked = true
                lastError = nil
            }
        } catch {
            lastError = (error as? LAError)?.localizedDescription ?? error.localizedDescription
        }
    }

    func lock() {
        isUnlocked = false
    }
}
