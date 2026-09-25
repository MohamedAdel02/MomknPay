//
//  MomknPayApp.swift
//  MomknPay
//
//  Created by Mohamed Adel on 23/09/2026.
//

import SwiftUI

@main
struct MomknPayApp: App {
    var body: some Scene {
        WindowGroup {
            BillDetailsView()
                .background(Color.ground.ignoresSafeArea())
        }
    }
}

