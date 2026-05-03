import SwiftUI
import SwiftData

@main
struct HushApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                if scenePhase != .active {
                    PrivacyOverlay()
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
            .animation(.easeInOut(duration: 0.15), value: scenePhase)
        }
        .modelContainer(for: [Site.self, VisitSession.self])
    }
}

private struct PrivacyOverlay: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.06, green: 0.11, blue: 0.18), Color(red: 0.02, green: 0.04, blue: 0.08)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 72, weight: .regular))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Hush")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.95))
            }
        }
    }
}
