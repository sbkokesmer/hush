import SwiftUI
import SwiftData
import WebKit

struct BrowserView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let site: Site

    @StateObject private var coordinator = PrivacyWebViewCoordinator()
    @State private var ruleList: WKContentRuleList?
    @State private var loadingRules = true
    @State private var session: VisitSession?
    @State private var startTime: Date = .now
    @State private var showingSiteInfo = false

    @AppStorage("blockTrackers") private var blockTrackers = true
    @AppStorage("hideFingerprint") private var hideFingerprint = true
    @AppStorage("blockClipboard") private var blockClipboard = true

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if loadingRules {
                ProgressView("Securing session…")
            } else if let url = site.url {
                PrivacyWebView(
                    url: url,
                    ruleList: ruleList,
                    blockTrackers: blockTrackers,
                    hideFingerprint: hideFingerprint,
                    blockClipboard: blockClipboard,
                    coordinator: coordinator
                )
                .ignoresSafeArea(edges: .bottom)
            } else {
                ContentUnavailableView("Invalid URL", systemImage: "exclamationmark.triangle", description: Text(site.urlString))
            }
        }
        .safeAreaInset(edge: .top) { topBar }
        .safeAreaInset(edge: .bottom) { bottomBar }
        .task {
            await prepareRules()
            startSession()
        }
        .onDisappear {
            endSession()
        }
        .statusBarHidden(false)
        .alert(item: $coordinator.blockedDownload) { d in
            Alert(
                title: Text("Download blocked"),
                message: Text("\(d.host) tried to download \"\(d.filename)\" (\(d.mimeType)).\n\nHush blocks file downloads to protect you from malware."),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $showingSiteInfo) {
            if let info = coordinator.siteInfo {
                SiteInfoView(
                    info: info,
                    blockedTrackers: coordinator.blockedCount,
                    isReaderMode: coordinator.isInReaderMode
                )
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { close() } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
            }
            VStack(spacing: 2) {
                Text(coordinator.pageTitle.isEmpty ? site.name : coordinator.pageTitle)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                    Text(coordinator.currentURL?.host() ?? site.displayHost)
                        .font(.caption)
                        .lineLimit(1)
                }
                .foregroundStyle(.secondary)
            }
            Spacer()
            Button { coordinator.reload() } label: {
                Image(systemName: coordinator.isLoading ? "xmark" : "arrow.clockwise")
                    .font(.headline)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
        .overlay(alignment: .bottom) {
            if coordinator.isLoading {
                ProgressView(value: coordinator.progress)
                    .progressViewStyle(.linear)
                    .frame(height: 2)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 28) {
            Button { coordinator.goBack() } label: {
                Image(systemName: "chevron.left").font(.title3)
            }.disabled(!coordinator.canGoBack)

            Button { coordinator.goForward() } label: {
                Image(systemName: "chevron.right").font(.title3)
            }.disabled(!coordinator.canGoForward)

            Spacer()

            Button { coordinator.enterReaderMode() } label: {
                Image(systemName: coordinator.isInReaderMode ? "doc.plaintext.fill" : "doc.plaintext")
                    .font(.title3)
                    .foregroundStyle(coordinator.isInReaderMode ? Color.accentColor : Color.primary)
            }

            Button {
                coordinator.showSiteInfo()
                showingSiteInfo = true
            } label: {
                Image(systemName: coordinator.siteInfo?.isSecure == true ? "lock.fill" : "lock.open.fill")
                    .font(.title3)
                    .foregroundStyle(coordinator.siteInfo?.isSecure == true ? .green : .red)
            }

            Spacer()

            Menu {
                Button(role: .destructive) {
                    clearAndReload()
                } label: { Label("Clear session", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis.circle").font(.title3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func prepareRules() async {
        do {
            ruleList = try await ContentBlocker.compile()
        } catch {
            ruleList = nil
        }
        loadingRules = false
    }

    private func startSession() {
        let s = VisitSession(site: site)
        context.insert(s)
        session = s
        startTime = .now
    }

    private func endSession() {
        guard let s = session else { return }
        s.endedAt = .now
        s.blockedTrackers = coordinator.blockedCount
        site.lastVisitedAt = .now
        site.totalVisitDuration += s.duration
        site.visitCount += 1
        site.blockedTrackerCount += coordinator.blockedCount
        try? context.save()
    }

    private func clearAndReload() {
        coordinator.reload()
    }

    private func close() {
        endSession()
        session = nil
        dismiss()
    }
}
