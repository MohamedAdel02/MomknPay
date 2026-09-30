//
//  ServicesViewModel.swift
//  MomknPay
//
//  Created by Mohamed Adel on 30/09/2026.
//

import SwiftUI
 
@Observable
class ServicesViewModel {
    
    var services: ServicesResponse = .dummy
    var query = ""
 
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        default:      return "Good evening"
        }
    }
 
    var sections: [(title: String, items: [Service])] {
        services.keys.sorted().compactMap { key in
            let all = services[key] ?? []
            let items = query.isEmpty ? all : all.filter { $0.name.localizedCaseInsensitiveContains(query) }
            return items.isEmpty ? nil : (key.uppercased(), items)
        }
    }
}
