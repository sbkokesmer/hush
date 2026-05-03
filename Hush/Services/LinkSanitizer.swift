import Foundation

enum LinkSanitizer {
    static let trackingParams: Set<String> = [
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content",
        "utm_id", "utm_name", "utm_brand", "utm_social", "utm_social-type",
        "utm_referrer", "utm_creative_format", "utm_marketing_tactic",
        "fbclid", "fb_action_ids", "fb_action_types", "fb_ref", "fb_source",
        "gclid", "gclsrc", "dclid", "wbraid", "gbraid",
        "msclkid", "mc_cid", "mc_eid",
        "yclid", "_openstat", "_ga",
        "icid", "ito", "iclid", "igshid", "irclickid",
        "vero_conv", "vero_id",
        "spm", "scm",
        "trk", "trk_contact", "trk_msg", "trk_module", "trk_sid",
        "li_fat_id", "li_share_id",
        "twclid", "ttclid",
        "ScCid", "scid", "snapchat_click_id",
        "_branch_match_id", "_branch_referrer",
        "rb_clickid", "s_cid",
        "hsa_acc", "hsa_cam", "hsa_grp", "hsa_ad", "hsa_src", "hsa_tgt", "hsa_kw", "hsa_mt", "hsa_net", "hsa_ver",
        "mkt_tok",
        "oly_anon_id", "oly_enc_id",
        "__s",
        "vgo_ee",
        "epik",
        "guce_referrer", "guce_referrer_sig",
        "ml_subscriber", "ml_subscriber_hash",
        "wickedid",
        "redirect_log_mongo_id", "redirect_mongo_id",
        "sb_referer_host",
        "ymclid",
        "ref_src", "ref_url"
    ]

    static func clean(_ url: URL) -> URL {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = components.queryItems, !items.isEmpty else {
            return url
        }
        let filtered = items.filter { !trackingParams.contains($0.name.lowercased()) && !trackingParams.contains($0.name) }
        if filtered.count == items.count {
            return url
        }
        components.queryItems = filtered.isEmpty ? nil : filtered
        return components.url ?? url
    }

    static func clean(_ string: String) -> String {
        guard let url = URL(string: string) else { return string }
        return clean(url).absoluteString
    }
}
