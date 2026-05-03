import Foundation
import Security
import Darwin

struct SiteSecurityInfo: Equatable {
    var host: String
    var scheme: String
    var isSecure: Bool
    var certificateCommonName: String?
    var certificateIssuer: String?
    var ipAddress: String?

    var schemeLabel: String {
        scheme.uppercased()
    }
}

enum SiteInfoResolver {
    static func extract(from trust: SecTrust, host: String, scheme: String) -> SiteSecurityInfo {
        var info = SiteSecurityInfo(
            host: host,
            scheme: scheme,
            isSecure: scheme.lowercased() == "https",
            certificateCommonName: nil,
            certificateIssuer: nil,
            ipAddress: nil
        )

        let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate] ?? []
        if let leaf = chain.first {
            var cn: CFString?
            SecCertificateCopyCommonName(leaf, &cn)
            info.certificateCommonName = cn as String?
        }
        if chain.count >= 2 {
            var issuerCN: CFString?
            SecCertificateCopyCommonName(chain[1], &issuerCN)
            info.certificateIssuer = issuerCN as String?
        } else if let leaf = chain.first {
            let summary = SecCertificateCopySubjectSummary(leaf) as String?
            info.certificateIssuer = summary
        }

        return info
    }

    static func resolveIP(host: String) -> String? {
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_STREAM,
            ai_protocol: 0,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil
        )
        var result: UnsafeMutablePointer<addrinfo>?
        guard getaddrinfo(host, nil, &hints, &result) == 0, let res = result else { return nil }
        defer { freeaddrinfo(res) }

        var ipBuffer = [CChar](repeating: 0, count: Int(INET6_ADDRSTRLEN))
        let addr = res.pointee
        if addr.ai_family == AF_INET {
            addr.ai_addr.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { ptr in
                var sin = ptr.pointee
                _ = inet_ntop(AF_INET, &sin.sin_addr, &ipBuffer, socklen_t(INET6_ADDRSTRLEN))
            }
        } else if addr.ai_family == AF_INET6 {
            addr.ai_addr.withMemoryRebound(to: sockaddr_in6.self, capacity: 1) { ptr in
                var sin6 = ptr.pointee
                _ = inet_ntop(AF_INET6, &sin6.sin6_addr, &ipBuffer, socklen_t(INET6_ADDRSTRLEN))
            }
        } else {
            return nil
        }
        return String(cString: ipBuffer)
    }
}
