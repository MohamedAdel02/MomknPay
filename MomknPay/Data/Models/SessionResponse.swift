//
//  SessionResponse.swift
//  MomknPay
//
//  Created by Mohamed Adel on 18/10/2026.
//

import Foundation

struct SessionResponse: Decodable {
    
    let sessionId: String
    let sessionKey: String
    let expiresAt: String
}
