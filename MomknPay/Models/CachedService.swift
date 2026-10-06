//
//  CachedService.swift
//  MomknPay
//
//  Created by Mohamed Adel on 06/10/2026.
//

import Foundation
import SwiftData

@Model
final class CachedService {
    @Attribute(.unique) var id: String
    var nameEn: String
    var nameAr: String
    var category: String
    var iconUrl: String?
    var inputLabel: String
    var inputPattern: String
    var minAmount: Int
    var maxAmount: Int
    var isActive: Bool
    var updatedAt: Date

    /// Keeps the server's order (sections are built by first appearance).
    var sortIndex: Int
    var syncedAt: Date

    init(_ s: Service, sortIndex: Int, syncedAt: Date) {
        id = s.id
        nameEn = s.nameEn
        nameAr = s.nameAr
        category = s.category
        iconUrl = s.iconUrl
        inputLabel = s.inputLabel
        inputPattern = s.inputPattern
        minAmount = s.minAmount
        maxAmount = s.maxAmount
        isActive = s.isActive
        updatedAt = s.updatedAt
        self.sortIndex = sortIndex
        self.syncedAt = syncedAt
    }

    var asService: Service {
        Service(id: id, nameEn: nameEn, nameAr: nameAr, category: category,
                iconUrl: iconUrl, inputLabel: inputLabel, inputPattern: inputPattern,
                minAmount: minAmount, maxAmount: maxAmount,
                isActive: isActive, updatedAt: updatedAt)
    }
}
