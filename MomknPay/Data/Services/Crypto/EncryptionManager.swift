//
//  EncryptionManager.swift
//  MomknPay
//
//  Created by Mohamed Adel on 07/10/2026.
//

import Foundation
import CryptoKit

enum EncryptionManager {

    static func encrypt(field: String, value: String, sessionKey: String) throws -> String {
        
        let key = try symmetricKey(from: sessionKey)
 
        let payload: [String: Any] = [
            field: value,
            "nonce": try randomHex(byteCount: 16),
            "ts": Int(Date().timeIntervalSince1970)
        ]
        
        let plaintext = try JSONSerialization.data(withJSONObject: payload)
 
        // AES.GCM.seal generates a fresh random 12-byte IV on every call.
        let sealed = try AES.GCM.seal(plaintext, using: key)
 
        // `combined` = iv(12) || ciphertext || tag(16), exactly the wire format.
        guard let combined = sealed.combined else { throw CryptoError.sealFailed }
        return combined.base64EncodedString()
    }
 
    static func symmetricKey(from base64: String) throws -> SymmetricKey {
        guard let keyData = Data(base64Encoded: base64), keyData.count == 32 else {
            throw CryptoError.invalidSessionKey
        }
        return SymmetricKey(data: keyData)
    }
 
    private static func randomHex(byteCount: Int) throws -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        guard SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes) == errSecSuccess else {
            throw CryptoError.randomGenerationFailed
        }
        return bytes.map { String(format: "%02x", $0) }.joined()
    }
}
