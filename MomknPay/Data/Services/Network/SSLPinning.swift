//
//  SSLPinning.swift
//  MomknPay
//
//  Created by Mohamed Adel on 13/10/2026.
//

import Foundation
import Security

class SSLPinning: NSObject, URLSessionDelegate {
 
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
 
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              let chain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let certificate = chain.first else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
 
        // Evaluate the certificate
        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
 
        // Local and remote certificate data
        let remoteCertificateData: NSData = SecCertificateCopyData(certificate)
 
        guard let pathToCertificate = Bundle.main.path(forResource: "momknpay.org", ofType: "cer"),
              let localCertificateData = NSData(contentsOfFile: pathToCertificate) else {
            print("Pinned certificate not found in bundle")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
 
        if isServerTrusted && remoteCertificateData.isEqual(to: localCertificateData as Data) {
            print("Certificate pinning succeeded")
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            print("Certificate pinning failed")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

}
