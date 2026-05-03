import Foundation
import SwiftData

@Model
final class VisitSession {
    @Attribute(.unique) var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var blockedTrackers: Int
    var site: Site?

    init(site: Site) {
        self.id = UUID()
        self.startedAt = .now
        self.endedAt = nil
        self.blockedTrackers = 0
        self.site = site
    }

    var duration: TimeInterval {
        let end = endedAt ?? .now
        return end.timeIntervalSince(startedAt)
    }
}
