//
//  EnvironmentValues+Extensions.swift
//  MomknPay
//
//  Created by Mohamed Adel on 06/10/2026.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var popToRoot = PopToRootAction(action: {})
}


struct PopToRootAction {
    let action: () -> Void

    func callAsFunction() {
        action()
    }
}

