//
//  MomknPayApp.swift
//  MomknPay
//
//  Created by Mohamed Adel on 23/09/2026.
//

import SwiftUI
import SwiftData

@main
struct MomknPayApp: App {

    private let repository: ServiceRepositoryProtocol

    init() {
        let container = try! ModelContainer(for: CachedService.self)
        repository = ServiceRepository(cache: SwiftDataServiceCache(modelContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                //ServicesView(viewModel: ServicesViewModel(repository: repository))
                ServicesView(viewModel: ServicesViewModel(repository: MockServiceRepository()))
            }
        }
    }
}

