//
//  Inquiry.swift
//  MomknPay
//
//  Created by Mohamed Adel on 03/10/2026.
//

import Foundation

struct InquiryRequest: Codable {
    let serviceId: String
    let payload: String
}
 
struct InquiryResponse: Codable {
    let inquiryId: String
    let serviceId: String
    let customerName: String
    let billMonth: String
    let amountDue: Int
    let serviceFee: Int
    let vat: Int
    let total: Int
    let currency: String
    let expiresAt: Date
}
