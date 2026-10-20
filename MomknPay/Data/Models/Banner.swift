//
//  Banner.swift
//  MomknPay
//
//  Created by Mohamed Adel on 20/10/2026.
//

import Foundation

struct Banner: Identifiable, Hashable {
    let id: Int
    let imageURL: URL?

    static let all: [Banner] = [
        Banner(id: 0, imageURL: URL(string: "https://example.com/banner1.png")),
        Banner(id: 1, imageURL: URL(string: "https://example.com/banner2.png")),
        Banner(id: 2, imageURL: URL(string: "https://example.com/banner3.png")),
        Banner(id: 3, imageURL: URL(string: "https://example.com/banner4.png"))
    ]
}
