import Foundation
import SwiftData

@Model
final class Site {
    @Attribute(.unique) var id: UUID
    var name: String
    var urlString: String
    var createdAt: Date
    var lastVisitedAt: Date?
    var totalVisitDuration: TimeInterval
    var visitCount: Int
    var blockedTrackerCount: Int

    @Relationship(deleteRule: .cascade, inverse: \VisitSession.site)
    var sessions: [VisitSession] = []

    init(name: String, urlString: String) {
        self.id = UUID()
        self.name = name
        self.urlString = urlString
        self.createdAt = .now
        self.lastVisitedAt = nil
        self.totalVisitDuration = 0
        self.visitCount = 0
        self.blockedTrackerCount = 0
    }

    var url: URL? {
        var s = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.lowercased().hasPrefix("http") {
            s = "https://" + s
        }
        guard let u = URL(string: s) else { return nil }
        return LinkSanitizer.clean(u)
    }

    var displayHost: String {
        url?.host() ?? urlString
    }

    var faviconURL: URL? {
        guard let host = url?.host() else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=128")
    }
}
