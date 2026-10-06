//
//  FileServiceCache.swift
//  MomknPay
//
//  Created by Mohamed Adel on 04/10/2026.
//

import Foundation
import SwiftData

protocol ServiceCaching {
    func load() async -> ServicesResponse?
    func save(_ response: ServicesResponse) async
}

@ModelActor
actor SwiftDataServiceCache: ServiceCaching {

    func load() -> ServicesResponse? {
        let descriptor = FetchDescriptor<CachedService>(sortBy: [SortDescriptor(\.sortIndex)])
        guard let rows = try? modelContext.fetch(descriptor),
              let first = rows.first else { return nil }
        return ServicesResponse(syncedAt: first.syncedAt, items: rows.map(\.asService))
    }

    func save(_ response: ServicesResponse) {
        do {
            try modelContext.delete(model: CachedService.self)
            for (index, service) in response.items.enumerated() {
                modelContext.insert(CachedService(service, sortIndex: index, syncedAt: response.syncedAt))
            }
            try modelContext.save()
        } catch {
            modelContext.rollback()
        }
    }
}
