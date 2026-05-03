import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var page = 0

    private let pages: [OnboardingPage] = [
        .init(
            icon: "shield.lefthalf.filled",
            title: "Welcome to Hush",
            subtitle: "A safer way to visit websites you don't fully trust.",
            bullets: []
        ),
        .init(
            icon: "eye.slash.fill",
            title: "Private by default",
            subtitle: "Every site opens in an isolated session.",
            bullets: [
                ("shield.fill", "Trackers and ads blocked"),
                ("person.fill.questionmark", "Device fingerprint hidden"),
                ("trash.fill", "Cookies and cache wiped on exit"),
                ("exclamationmark.shield.fill", "Phishing & malware warnings")
            ]
        ),
        .init(
            icon: "exclamationmark.triangle.fill",
            title: "What Hush doesn't do",
            subtitle: "Be honest about the limits, so you stay safe.",
            bullets: [
                ("network", "Hush is NOT a VPN — your real IP is still visible to sites"),
                ("antenna.radiowaves.left.and.right", "Doesn't hide your location or country"),
                ("person.crop.circle.badge.questionmark", "If you log in, the site knows it's you"),
                ("ladybug.fill", "Not an antivirus — use common sense too")
            ]
        ),
        .init(
            icon: "globe.badge.chevron.backward",
            title: "Add your first site",
            subtitle: "Add any forum, news site, or anything you'd rather not share with your everyday browser.",
            bullets: []
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { idx, p in
                    OnboardingPageView(page: p).tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? Color.accentColor : Color.secondary.opacity(0.25))
                        .frame(width: i == page ? 22 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.2), value: page)
                }
            }
            .padding(.bottom, 28)

            Button(action: advance) {
                Text(page == pages.count - 1 ? "Get started" : "Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
        .interactiveDismissDisabled()
    }

    private func advance() {
        if page < pages.count - 1 {
            withAnimation { page += 1 }
        } else {
            isPresented = false
        }
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let bullets: [(String, String)]
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(maxHeight: 60)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.accentColor.opacity(0.12),
                                Color.accentColor.opacity(0.04)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 112, height: 112)
                Circle()
                    .stroke(Color.accentColor.opacity(0.10), lineWidth: 1)
                    .frame(width: 112, height: 112)
                Image(systemName: page.icon)
                    .font(.system(size: 48, weight: .regular))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(.bottom, 32)

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 36)

            if !page.bullets.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(page.bullets.enumerated()), id: \.offset) { idx, bullet in
                        HStack(spacing: 14) {
                            Image(systemName: bullet.0)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 28, height: 28)
                            Text(bullet.1)
                                .font(.system(size: 15))
                                .foregroundStyle(.primary)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)
                        if idx < page.bullets.count - 1 {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.secondary.opacity(0.08))
                )
                .padding(.horizontal, 24)
                .padding(.top, 28)
            }

            Spacer()
        }
    }
}
