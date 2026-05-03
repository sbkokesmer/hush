import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Site.lastVisitedAt, order: .reverse), SortDescriptor(\Site.createdAt, order: .reverse)])
    private var sites: [Site]

    @State private var showAdd = false
    @State private var openedSite: Site?

    var body: some View {
        NavigationStack {
            Group {
                if sites.isEmpty {
                    EmptyStateView { showAdd = true }
                } else {
                    List {
                        ForEach(sites) { site in
                            Button { openedSite = site } label: {
                                SiteRowView(site: site)
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Hush")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus.circle.fill").font(.title2) }
                }
            }
            .sheet(isPresented: $showAdd) { AddSiteView() }
            .fullScreenCover(item: $openedSite) { site in
                BrowserView(site: site)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets { context.delete(sites[index]) }
    }
}

private struct EmptyStateView: View {
    let onAdd: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.lefthalf.filled")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("No sites yet")
                .font(.title2.bold())
            Text("Add a site to visit it safely.\nNo cookies, no trackers, no fingerprint.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button(action: onAdd) {
                Label("Add a site", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor, in: Capsule())
                    .foregroundStyle(.white)
            }
            .padding(.top, 8)
        }
        .padding()
    }
}
