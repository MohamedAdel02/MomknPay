//
//  Service.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//
import SwiftUI

struct ServiceSection: Identifiable {
    let title: String
    let items: [Service]
    var id: String { title }
}

struct ServicesResponse: Codable {
    let syncedAt: Date
    let items: [Service]
}

struct Service: Codable, Hashable, Identifiable {
    let id: String
    let nameEn: String
    let nameAr: String
    let category: String
    let iconUrl: String?
    let inputLabel: String
    let inputPattern: String
    let minAmount: Int
    let maxAmount: Int
    let isActive: Bool
    let updatedAt: Date

    var available: Bool { isActive }

    func matches(_ query: String) -> Bool {
        nameEn.localizedCaseInsensitiveContains(query) || nameAr.localizedCaseInsensitiveContains(query)
    }

}
