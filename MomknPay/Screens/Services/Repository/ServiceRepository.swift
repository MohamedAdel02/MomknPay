//
//  ServiceRepository.swift
//  MomknPay
//
//  Created by Mohamed Adel on 04/10/2026.
//

import Foundation

struct ServicesSnapshot {
    let services: [Service]
    let syncedAt: Date
    
    /// true when the network failed and this is the saved copy.
    let isStale: Bool
}

protocol ServiceRepositoryProtocol {
    func fetchServices() async throws -> ServicesSnapshot
}

final class ServiceRepository: ServiceRepositoryProtocol {

    private let network: NetworkManager
    private let cache: ServiceCaching

    init(network: NetworkManager = .shared, cache: ServiceCaching = FileServiceCache()) {
        self.network = network
        self.cache = cache
    }

    func fetchServices() async throws -> ServicesSnapshot {
        do {
            let request = try Endpoint.services.asHTTPRequest()
            let response = try await network.send(request, as: ServicesResponse.self)
            cache.save(response)
            return ServicesSnapshot(services: response.items, syncedAt: response.syncedAt, isStale: false)

        } catch let error as NetworkError where error.allowsCacheFallback {
            // Network-level problem: show the saved list if we have one.
            guard let cached = cache.load() else { throw error }
            return ServicesSnapshot(services: cached.items, syncedAt: cached.syncedAt, isStale: true)
        }
    }
}



// MARK: - Mock (previews / tests)

struct MockServiceRepository: ServiceRepositoryProtocol {

    var result: Result<[Service], NetworkError> = .success(Service.samples)
    var stale = false
    var delay: Duration = .milliseconds(400)

    func fetchServices() async throws -> ServicesSnapshot {
        try await Task.sleep(for: delay)
        let services = try result.get()
        return ServicesSnapshot(
            services: services,
            syncedAt: Date().addingTimeInterval(stale ? -2 * 3600 : 0),
            isStale: stale
        )
    }
}

extension Service {
    static let samples: [Service] = [
        make("1", "Cairo Electricity", "كهرباء القاهرة", "electricity", active: true),
        make("2", "Alexandria Electricity", "كهرباء الإسكندرية", "electricity", active: false),
        make("3", "Greater Cairo Water", "مياه القاهرة الكبرى", "water", active: true),
        make("4", "Town Gas", "غاز المدن", "gas", active: true)
    ]

    private static func make(_ id: String, _ en: String, _ ar: String, _ category: String, active: Bool) -> Service {
        Service(id: id, nameEn: en, nameAr: ar, category: category, iconUrl: nil,
                inputLabel: "Subscriber number", inputPattern: "^[0-9]{8,12}$",
                minAmount: 5, maxAmount: 5000, isActive: active, updatedAt: Date())
    }
}
