//
//  Service.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//
import SwiftUI

struct Service: Identifiable, Codable, Hashable {
    
    let id: Int
    let name: String
    let available: Bool
}

typealias ServicesResponse = [String: [Service]]

extension ServicesResponse {
    static let dummy: ServicesResponse = [
        "electricity": [
            Service(id: 1, name: "Cairo Electricity", available: true),
            Service(id: 2, name: "Alexandria Electricity", available: false)
        ],
        "water": [
            Service(id: 3, name: "Greater Cairo Water", available: true)
        ],
        "gas": [
            Service(id: 4, name: "Town Gas", available: true)
        ]
    ]
}
