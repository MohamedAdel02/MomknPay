//
//  Service.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//
import SwiftUI

struct ServicesResponse: Decodable {
    let syncedAt: Date
    let items: [Service]
}

struct Service: Decodable {
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
}
