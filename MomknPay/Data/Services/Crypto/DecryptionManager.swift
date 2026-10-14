//
//  DecryptionManager.swift
//  MomknPay
//
//  Created by Mohamed Adel on 07/10/2026.
//

import CryptoKit
import Foundation
 
enum DecryptionManager {
 
    static func decrypt(ciphertextBase64: String, sessionKey: String) throws -> [String: Any] {
        
        let key = try EncryptionManager.symmetricKey(from: sessionKey)
 
        guard let combined = Data(base64Encoded: ciphertextBase64) else {
            throw CryptoError.invalidCiphertext
        }
 
        // Splits into iv (12) + ciphertext + tag (16).
        let box = try AES.GCM.SealedBox(combined: combined)
        
        let plaintext = try AES.GCM.open(box, using: key)
 
        guard let json = try JSONSerialization.jsonObject(with: plaintext) as? [String: Any] else {
            throw CryptoError.invalidJSON
        }
        
        return json
    }
}
 
