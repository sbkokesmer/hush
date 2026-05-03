import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \Site.totalVisitDuration, order: .reverse) private var sites: [Site]

    private var totalSeconds: TimeInterval { sites.reduce(0) { $0 + $1.totalVisitDuration } }
    private var totalBlocked: Int { sites.reduce(0) { $0 + $1.blockedTrackerCount } }
    private var totalVisits: Int { sites.reduce(0) { $0 + $1.visitCount } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        StatCard(value: "\(totalBlocked)", label: "Trackers blocked", systemImage: "shield.fill", tint: .green)
                        StatCard(value: "\(totalVisits)", label: "Visits", systemImage: "globe", tint: .blue)
                    }
                    StatCard(value: formatDuration(totalSeconds), label: "Total time browsing safely", systemImage: "clock.fill", tint: .orange, wide: true)

                    if !sites.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Top sites")
                                .font(.headline)
                                .padding(.horizontal, 4)
                            ForEach(sites.prefix(10)) { site in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(site.name).font(.subheadline.weight(.semibold))
                                        Text(site.displayHost).font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(formatDuration(site.totalVisitDuration))
                                            .font(.subheadline.monospacedDigit())
                                        Text("\(site.visitCount) visits")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    } else {
                        ContentUnavailableView(
                            "No data yet",
                            systemImage: "chart.bar",
                            description: Text("Visit a site to start collecting privacy stats.")
                        )
                        .padding(.top, 40)
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy")
        }
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let s = Int(seconds)
        let h = s / 3600, m = (s % 3600) / 60, sec = s % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(sec)s" }
        return "\(sec)s"
    }
}

private struct StatCard: View {
    let value: String
    let label: String
    let systemImage: String
    let tint: Color
    var wide: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: systemImage).font(.title3).foregroundStyle(tint)
            Text(value).font(.title.bold().monospacedDigit())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
