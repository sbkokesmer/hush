import SwiftUI
import WebKit

@MainActor
final class PrivacyWebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, ObservableObject {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false
    @Published var progress: Double = 0
    @Published var pageTitle: String = ""
    @Published var blockedCount: Int = 0
    @Published var currentURL: URL?
    @Published var blockedDownload: BlockedDownload?
    @Published var siteInfo: SiteSecurityInfo?
    @Published var isInReaderMode = false

    struct BlockedDownload: Identifiable, Equatable {
        let id = UUID()
        let filename: String
        let mimeType: String
        let host: String
    }

    private var observers: [NSKeyValueObservation] = []
    private(set) weak var webView: WKWebView?

    func attach(_ webView: WKWebView) {
        self.webView = webView
        observers.append(webView.observe(\.canGoBack, options: [.new]) { [weak self] _, change in
            Task { @MainActor in self?.canGoBack = change.newValue ?? false }
        })
        observers.append(webView.observe(\.canGoForward, options: [.new]) { [weak self] _, change in
            Task { @MainActor in self?.canGoForward = change.newValue ?? false }
        })
        observers.append(webView.observe(\.isLoading, options: [.new]) { [weak self] _, change in
            Task { @MainActor in self?.isLoading = change.newValue ?? false }
        })
        observers.append(webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
            Task { @MainActor in self?.progress = change.newValue ?? 0 }
        })
        observers.append(webView.observe(\.title, options: [.new]) { [weak self] _, change in
            Task { @MainActor in self?.pageTitle = change.newValue?.flatMap { $0 } ?? "" }
        })
        observers.append(webView.observe(\.url, options: [.new]) { [weak self] _, change in
            Task { @MainActor in self?.currentURL = change.newValue.flatMap { $0 } }
        })
    }

    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func reload() {
        isInReaderMode = false
        webView?.reload()
    }
    func stopLoading() { webView?.stopLoading() }

    func enterReaderMode() {
        guard let webView, !isInReaderMode else { return }
        webView.evaluateJavaScript(ReaderMode.script) { [weak self] _, _ in
            Task { @MainActor in self?.isInReaderMode = true }
        }
    }

    func showSiteInfo() {
        guard let url = currentURL ?? webView?.url, var info = siteInfo else {
            if let host = (currentURL ?? webView?.url)?.host(),
               let scheme = (currentURL ?? webView?.url)?.scheme {
                var fallback = SiteSecurityInfo(host: host, scheme: scheme, isSecure: scheme.lowercased() == "https",
                                                certificateCommonName: nil, certificateIssuer: nil, ipAddress: nil)
                Task.detached(priority: .userInitiated) {
                    let ip = SiteInfoResolver.resolveIP(host: host)
                    await MainActor.run {
                        fallback.ipAddress = ip
                        self.siteInfo = fallback
                    }
                }
            }
            return
        }
        if info.ipAddress == nil {
            let host = url.host() ?? info.host
            Task.detached(priority: .userInitiated) {
                let ip = SiteInfoResolver.resolveIP(host: host)
                await MainActor.run {
                    info.ipAddress = ip
                    self.siteInfo = info
                }
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        if let scheme = url.scheme?.lowercased(),
           !["http", "https", "about", "data", "blob"].contains(scheme) {
            decisionHandler(.cancel)
            return
        }
        let cleaned = LinkSanitizer.clean(url)
        if cleaned != url, navigationAction.targetFrame?.isMainFrame == true {
            decisionHandler(.cancel)
            var newRequest = navigationAction.request
            newRequest.url = cleaned
            webView.load(newRequest)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if !navigationResponse.canShowMIMEType {
            let response = navigationResponse.response
            let filename = response.suggestedFilename ?? response.url?.lastPathComponent ?? "file"
            let mime = response.mimeType ?? "application/octet-stream"
            let host = response.url?.host() ?? ""
            Task { @MainActor in
                self.blockedDownload = BlockedDownload(filename: filename, mimeType: mime, host: host)
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust,
           challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let host = challenge.protectionSpace.host
            let scheme = webView.url?.scheme ?? "https"
            let info = SiteInfoResolver.extract(from: trust, host: host, scheme: scheme)
            Task { @MainActor in self.siteInfo = info }
            completionHandler(.performDefaultHandling, URLCredential(trust: trust))
            return
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    deinit {
        observers.forEach { $0.invalidate() }
    }
}

struct PrivacyWebView: UIViewRepresentable {
    let url: URL
    let ruleList: WKContentRuleList?
    let blockTrackers: Bool
    let hideFingerprint: Bool
    let blockClipboard: Bool
    @ObservedObject var coordinator: PrivacyWebViewCoordinator

    func makeCoordinator() -> PrivacyWebViewCoordinator { coordinator }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.suppressesIncrementalRendering = false
        config.allowsInlineMediaPlayback = true
        config.applicationNameForUserAgent = "Version/17.0 Mobile/15E148 Safari/604.1"
        config.preferences.isFraudulentWebsiteWarningEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.upgradeKnownHostsToHTTPS = true

        let userContent = WKUserContentController()
        for script in FingerprintProtection.userScript(includeFingerprint: hideFingerprint, includeClipboard: blockClipboard) {
            userContent.addUserScript(script)
        }
        if let ruleList, blockTrackers { userContent.add(ruleList) }
        config.userContentController = userContent

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

        context.coordinator.attach(webView)
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}
