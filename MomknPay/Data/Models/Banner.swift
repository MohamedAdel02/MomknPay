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
 
    /// Sample data for SwiftUI previews only.
    static let samples: [Banner] = (1...4).map {
        Banner(id: "sample_\($0)",
               titleEn: "Sample \($0)",
               titleAr: "عينة \($0)",
               imageURL: URL(string: "https://example.com/banner\($0).png"),
               linkURL: nil)
    }
}
