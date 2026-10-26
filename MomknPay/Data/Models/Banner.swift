//
//  Banner.swift
//  MomknPay
//
//  Created by Mohamed Adel on 20/10/2026.
//

import Foundation

struct AdsResponse: Decodable {
    let items: [Banner]
}

struct Banner: Identifiable, Hashable, Decodable {
    let id: String
    let titleEn: String
    let titleAr: String
    let imageURL: URL?
    let linkURL: URL?
    var localImageName: String? = nil

    private enum CodingKeys: String, CodingKey {
        case id, titleEn, titleAr
        case imageURL = "imageUrl"
        case linkURL = "linkUrl"
    }
}

extension Banner {

    static let placeholders: [Banner] = (0..<4).map {
        Banner(id: "placeholder_\($0)", titleEn: "", titleAr: "", imageURL: nil, linkURL: nil)
    }

    /// Shown when the network request fails. Uses the local Banner assets.
    static let mocks: [Banner] = [
        Banner(id: "mock_nbe",
               titleEn: "National Bank of Egypt: accounts, cards and digital banking",
               titleAr: "البنك الأهلي المصري: حسابات وبطاقات وخدمات رقمية",
               imageURL: nil,
               linkURL: URL(string: "https://www.nbe.com.eg"),
               localImageName: "banner1"),
        Banner(id: "mock_vodafone",
               titleEn: "Recharge and pay your Vodafone line in seconds",
               titleAr: "اشحن وادفع خط فودافون في ثوانٍ",
               imageURL: nil,
               linkURL: URL(string: "https://web.vodafone.com.eg"),
               localImageName: "banner2"),
        Banner(id: "mock_we",
               titleEn: "Pay your WE landline and internet in one tap",
               titleAr: "ادفع الخط الأرضي وإنترنت وي بلمسة واحدة",
               imageURL: nil,
               linkURL: URL(string: "https://te.eg"),
               localImageName: "banner3"),
        Banner(id: "mock_orange",
               titleEn: "Top up Orange and pay your home internet",
               titleAr: "اشحن أورنج وادفع إنترنت المنزل",
               imageURL: nil,
               linkURL: URL(string: "https://www.orange.eg"),
               localImageName: "banner4")
    ]

    /// Sample data for SwiftUI previews only.
    static let samples: [Banner] = (1...4).map {
        Banner(id: "sample_\($0)",
               titleEn: "Sample \($0)",
               titleAr: "عينة \($0)",
               imageURL: URL(string: "https://example.com/banner\($0).png"),
               linkURL: nil)
    }
}
