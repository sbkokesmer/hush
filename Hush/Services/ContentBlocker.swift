import Foundation
import WebKit

enum ContentBlocker {
    static let identifier = "HushTrackerBlockerV2"

    static func loadRulesJSON() -> String {
        if let url = Bundle.main.url(forResource: "blocker-rules", withExtension: "json"),
           let str = try? String(contentsOf: url, encoding: .utf8) {
            return str
        }
        return fallbackRules
    }

    private static let fallbackRules: String = """
    [
      { "trigger": { "url-filter": ".*", "if-domain": ["*google-analytics.com","*googletagmanager.com","*doubleclick.net"] }, "action": { "type": "block" } },
      { "trigger": { "url-filter": ".*", "load-type": ["third-party"], "resource-type": ["raw"] }, "action": { "type": "block-cookies" } },
      { "trigger": { "url-filter": ".*" }, "action": { "type": "make-https" } }
    ]
    """

    @MainActor
    static func compile() async throws -> WKContentRuleList? {
        let store = WKContentRuleListStore.default()
        let json = loadRulesJSON()
        return try await withCheckedThrowingContinuation { cont in
            store?.compileContentRuleList(forIdentifier: identifier, encodedContentRuleList: json) { list, error in
                if let error { cont.resume(throwing: error); return }
                cont.resume(returning: list)
            }
        }
    }
}
