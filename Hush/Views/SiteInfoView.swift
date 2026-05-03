import SwiftUI

struct SiteInfoView: View {
    let info: SiteSecurityInfo
    let blockedTrackers: Int
    let isReaderMode: Bool

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: info.isSecure ? "lock.fill" : "lock.open.fill")
                            .foregroundStyle(info.isSecure ? .green : .red)
                            .font(.title2)
                        VStack(alignment: .leading) {
                            Text(info.host).font(.headline)
                            Text(info.isSecure ? "Encrypted (HTTPS)" : "Not encrypted (HTTP)")
                                .font(.subheadline)
                                .foregroundStyle(info.isSecure ? .green : .red)
                        }
                    }
                }

                if info.isSecure {
                    Section("Certificate") {
                        if let cn = info.certificateCommonName {
                            row("Issued to", cn)
                        }
                        if let issuer = info.certificateIssuer {
                            row("Issued by", issuer)
                        }
                        if info.certificateCommonName == nil && info.certificateIssuer == nil {
                            Text("Certificate details unavailable")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Network") {
                    if let ip = info.ipAddress {
                        row("Server IP", ip)
                    } else {
                        HStack {
                            Text("Server IP")
                            Spacer()
                            ProgressView().controlSize(.small)
                        }
                    }
                    row("Scheme", info.schemeLabel)
                }

                Section("This session") {
                    HStack {
                        Label("Trackers blocked", systemImage: "shield.fill")
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(blockedTrackers)").monospacedDigit()
                    }
                    HStack {
                        Label("Reader mode", systemImage: "doc.plaintext")
                            .foregroundStyle(.blue)
                        Spacer()
                        Text(isReaderMode ? "On" : "Off").foregroundStyle(.secondary)
                    }
                    HStack {
                        Label("Cookies & cache", systemImage: "trash")
                            .foregroundStyle(.orange)
                        Spacer()
                        Text("Will be cleared").foregroundStyle(.secondary).font(.caption)
                    }
                }

                Section {
                    Label("Hush opens this site in an isolated session. Cookies, cache, and storage are wiped when you close the tab.",
                          systemImage: "lock.shield")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Site Info")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
    }
}
