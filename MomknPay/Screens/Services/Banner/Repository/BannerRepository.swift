//
//  BannerRepository.swift
//  MomknPay
//
//  Created by Mohamed Adel on 22/10/2026.
//

import Foundation

protocol BannerRepositoryProtocol {
    func fetchBanners() async throws -> [Banner]
}

final class BannerRepository: BannerRepositoryProtocol {

    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func fetchBanners() async throws -> [Banner] {
        let request = try Endpoint.ads.asHTTPRequest()
        let response = try await networkManager.send(request, as: AdsResponse.self)
        return response.items
    }
}
