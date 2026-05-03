import SwiftUI

struct RootView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("requireFaceID") private var requireFaceID = false
    @State private var showOnboarding = false
    @StateObject private var gate = BiometricGate()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .tabItem { Label("Sites", systemImage: "globe") }
                StatsView()
                    .tabItem { Label("Privacy", systemImage: "shield.lefthalf.filled") }
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape") }
            }
            .tint(Color("AccentColor"))

            if requireFaceID && !gate.isUnlocked {
                LockScreen(gate: gate)
                    .transition(.opacity)
                    .zIndex(50)
            }
        }
        .onAppear {
            if !hasSeenOnboarding { showOnboarding = true }
            if requireFaceID { Task { await gate.unlock() } }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background && requireFaceID {
                gate.lock()
            }
            if phase == .active && requireFaceID && !gate.isUnlocked {
                Task { await gate.unlock() }
            }
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: { hasSeenOnboarding = true }) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

private struct LockScreen: View {
    @ObservedObject var gate: BiometricGate

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "faceid")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.accentColor)
                Text("Hush is locked")
                    .font(.title2.weight(.semibold))
                if let err = gate.lastError {
                    Text(err)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Button {
                    Task { await gate.unlock() }
                } label: {
                    Text("Unlock")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.accentColor, in: Capsule())
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
