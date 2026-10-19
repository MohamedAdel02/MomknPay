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

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let repository: ServiceRepositoryProtocol
    @State private var path = NavigationPath()

    init() {
        let container = try! ModelContainer(for: CachedService.self)
        repository = ServiceRepository(cache: SwiftDataServiceCache(modelContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                ServicesView(viewModel: ServicesViewModel(repository: repository))
//                ServicesView(viewModel: ServicesViewModel(repository: MockServiceRepository()))
            }
            .environment(\.popToRoot, PopToRootAction { path = NavigationPath() })
            .withToast()
            .task {
                do {
                    let session = try await SessionManager.shared.currentSession()
                    print("Session OK:", session.id)
                    print(session.expiresAt)
                } catch {
                    print("Session failed:", error)
                }
            }
        }
    }
}

