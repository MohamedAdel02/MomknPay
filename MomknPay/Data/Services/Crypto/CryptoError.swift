//
//  CryptoError.swift
//  MomknPay
//
//  Created by Mohamed Adel on 07/10/2026.
//

import Foundation

enum CryptoError: Error {
    case invalidSessionKey      // not valid base64, or not exactly 32 bytes
    case randomGenerationFailed // SecRandomCopyBytes failed
    case sealFailed             // AES.GCM could not produce the combined box
    case invalidCiphertext      // not valid base64
    case invalidJSON            // decrypted OK, but plaintext isn't a JSON object
}
