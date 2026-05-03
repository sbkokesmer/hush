import SwiftUI

struct SiteRowView: View {
    let site: Site

    var body: some View {
        HStack(spacing: 14) {
            FaviconView(url: site.faviconURL)
            VStack(alignment: .leading, spacing: 4) {
                Text(site.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(site.displayHost)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let last = site.lastVisitedAt {
                    Text("Last visit: \(last.formatted(.relative(presentation: .numeric)))")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    Text("Never visited")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

private struct FaviconView: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let img):
                img.resizable().aspectRatio(contentMode: .fit)
            default:
                Image(systemName: "globe").foregroundStyle(.secondary)
            }
        }
        .frame(width: 36, height: 36)
        .padding(6)
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }
}
