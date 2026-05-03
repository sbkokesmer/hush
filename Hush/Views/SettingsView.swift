import SwiftUI
import SwiftData
import WebKit

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var sites: [Site]
    @Query private var sessions: [VisitSession]

    @AppStorage("blockTrackers") private var blockTrackers = true
    @AppStorage("hideFingerprint") private var hideFingerprint = true
    @AppStorage("blockClipboard") private var blockClipboard = true
    @AppStorage("requireFaceID") private var requireFaceID = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var showDeleteConfirm = false
    @State private var deletionMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle(isOn: $blockTrackers) {
                        Label("Block trackers & ads", systemImage: "shield.fill")
                    }
                    Toggle(isOn: $hideFingerprint) {
                        Label("Hide device fingerprint", systemImage: "person.fill.questionmark")
                    }
                    Toggle(isOn: $blockClipboard) {
                        Label("Block clipboard reading", systemImage: "doc.on.clipboard")
                    }
                } header: { Text("Protection") } footer: {
                    Text("Changes apply to new sessions. Close and reopen a site to take effect.")
                }

                Section {
                    Toggle(isOn: $requireFaceID) {
                        Label("Require Face ID", systemImage: "faceid")
                    }
                } header: { Text("App lock") } footer: {
                    Text("You'll be asked to authenticate every time Hush returns to the foreground.")
                }

                Section {
                    HStack {
                        Label("Safe Browsing", systemImage: "exclamationmark.shield")
                        Spacer()
                        Image(systemName: "checkmark").foregroundStyle(.green)
                    }
                    HStack {
                        Label("Block file downloads", systemImage: "arrow.down.doc.fill")
                        Spacer()
                        Image(systemName: "checkmark").foregroundStyle(.green)
                    }
                    HStack {
                        Label("Clear session on exit", systemImage: "trash")
                        Spacer()
                        Image(systemName: "checkmark").foregroundStyle(.green)
                    }
                    HStack {
                        Label("Strip tracking parameters", systemImage: "link.badge.plus")
                        Spacer()
                        Image(systemName: "checkmark").foregroundStyle(.green)
                    }
                    HStack {
                        Label("HTTPS upgrade", systemImage: "lock.fill")
                        Spacer()
                        Image(systemName: "checkmark").foregroundStyle(.green)
                    }
                } header: { Text("Always on") } footer: {
                    Text("Core protections built into every session. They cannot be turned off.")
                }

                Section {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete all data", systemImage: "trash.fill")
                    }
                } header: { Text("Data") } footer: {
                    Text("Removes \(sites.count) site\(sites.count == 1 ? "" : "s"), \(sessions.count) visit record\(sessions.count == 1 ? "" : "s"), all browsing data, and resets all settings.")
                }

                Section {
                    Label("Hush keeps no logs and sends nothing to a server. Everything stays on your device.",
                          systemImage: "lock.shield.fill")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Link(destination: URL(string: "https://sbkokesmer.github.io/hush/PRIVACY")!) {
                        Label("Privacy policy", systemImage: "doc.text")
                    }
                    Link(destination: URL(string: "https://sbkokesmer.github.io/hush/SUPPORT")!) {
                        Label("Support", systemImage: "questionmark.circle")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion).foregroundStyle(.secondary)
                    }
                } header: { Text("About") }
            }
            .navigationTitle("Settings")
            .alert("Delete all data?", isPresented: $showDeleteConfirm) {
                Button("Delete everything", role: .destructive, action: deleteEverything)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently removes all sites, visit history, browsing data, and resets every setting. This action cannot be undone.")
            }
            .alert("Done", isPresented: .init(get: { deletionMessage != nil }, set: { if !$0 { deletionMessage = nil } })) {
                Button("OK") { deletionMessage = nil }
            } message: {
                Text(deletionMessage ?? "")
            }
        }
    }

    private func deleteEverything() {
        for site in sites { context.delete(site) }
        for session in sessions { context.delete(session) }
        try? context.save()

        let defaults = UserDefaults.standard
        for key in ["blockTrackers", "hideFingerprint", "blockClipboard", "requireFaceID", "hasSeenOnboarding"] {
            defaults.removeObject(forKey: key)
        }

        Task {
            let types = WKWebsiteDataStore.allWebsiteDataTypes()
            await WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: .distantPast)
            await MainActor.run {
                deletionMessage = "All data has been deleted."
            }
        }
    }
}

private extension Bundle {
    var appVersion: String {
        let v = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }
}
