//
//  APIErrorEnvelope.swift
//  MomknPay
//
//  Created by Mohamed Adel on 03/10/2026.
//

import Foundation

struct APIErrorEnvelope: Decodable {
    
    let error: Body
    
    struct Body: Decodable {
        let code: String
        let messageEn: String?
        let messageAr: String?
        let field: String?
    }
}


