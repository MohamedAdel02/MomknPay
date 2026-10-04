//
//  ServicesViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//

import SwiftUI

@Observable
class ServicesViewModel {

    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(NetworkError)
    }

    private let repository: ServiceRepositoryProtocol

    private(set) var services: [Service] = []
    private(set) var state: LoadState = .idle
    private(set) var syncedAt: Date?
    
    /// true while we are showing the saved copy because the network failed.
    private(set) var isStale = false

    var query = ""

    var refreshError: NetworkError?

    init(repository: ServiceRepositoryProtocol = MockServiceRepository()) {
        self.repository = repository
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }

   var sections: [ServiceSection] {
       let filtered = query.isEmpty ? services : services.filter { $0.matches(query) }

       var order: [String] = []
       var groups: [String: [Service]] = [:]

       for service in filtered {
           if groups[service.category] == nil { order.append(service.category) }
           groups[service.category, default: []].append(service)
       }

       return order.map { ServiceSection(title: $0, items: groups[$0] ?? []) }
   }
    

    var isSearching: Bool { !query.isEmpty }

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await load()
    }


    func load() async {
        
        let hadData = !services.isEmpty
        
        if !hadData { state = .loading }

        do {
            let snapshot = try await repository.fetchServices()
            services = snapshot.services
            syncedAt = snapshot.syncedAt
            isStale = snapshot.isStale
            state = .loaded
        } catch {
            let networkError = Self.map(error)

            if networkError == .cancelled {
                state = hadData ? .loaded : .idle
                return
            }

            if hadData {
                state = .loaded
                refreshError = networkError
            } else {
                state = .failed(networkError)
            }
        }
    }

    private static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError { return networkError }
        if error is CancellationError { return .cancelled }
        if let urlError = error as? URLError { return .from(urlError: urlError) }
        return .unknown(error.localizedDescription)
    }
}
