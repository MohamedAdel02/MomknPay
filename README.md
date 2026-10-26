<p align="center">
<img src="https://github.com/user-attachments/assets/f0b5f3a5-668f-4180-b5b3-e54050978133" width="200">
</p>

MomknPay is a mock bill payment app built in Swift using SwiftUI and MVVM architecture.<br>
It lets users browse utility services, look up a bill by subscriber number, and pay it securely. Services are cached locally with SwiftData for offline use.

## Preview


## Features

**Behind the scenes**

- **Encrypted sensitive data:** the subscriber number and the CVV are never sent in plain text. Each value is wrapped in a payload with a random nonce and timestamp, then encrypted with AES-GCM (CryptoKit) using a per-session 256-bit key from `POST /sessions`. Every encryption uses a fresh random IV.
- **Session key management:** the session is cached and treated as expired 60 seconds early, concurrent requests share a single fetch, and an expired session is refreshed automatically with one retry on `SESSION_EXPIRED`.
- **SSL (certificate) pinning:** `SSLPinning` validates the server's certificate and compares it with a certificate bundled in the app, rejecting any mismatch to block man-in-the-middle attacks. It is implemented but not enabled yet (see Known gaps).
- **Offline caching with SwiftData:** the services list is saved after every successful fetch. If the network fails, the app falls back to the saved copy and flags it as stale with the last sync time. API errors are not hidden by the cache.

**In the app**

- **Browse and search services:** grouped by category and searchable in English and Arabic. Inactive services are shown but can't be opened.
- **Promo banners:** a carousel at the top of the list, loaded from the ads endpoint.
- **Fees inquiry:** the input label and validation rules come from the API per service, and digits are grouped in fours as you type.
- **Bill details:** amount due, service fee, VAT and total in EGP, with a five-minute quote countdown.
- **CVV confirmation:** entered on a custom keypad in a sheet. A wrong CVV shakes and resets.
- **Result screens:** success and failure screens with the payment reference, and a share button on success.

## Architecture

MVVM with a repository layer. View models use the `@Observable` macro, and repositories sit behind protocols so each screen can run against a mock.

```
MomknPay/
├── Core/                  App entry point, AppDelegate (Firebase), AppConfig
├── Data/
│   ├── Models/            Codable API models + SwiftData CachedService
│   └── Services/
│       ├── Network/       NetworkManager, endpoints, typed NetworkError, SSL pinning
│       ├── Session/       Crypto session lifecycle
│       ├── Crypto/        AES-GCM encryption
│       ├── Cashing/       SwiftData services cache
│       └── BiometricAuth/ LocalAuthentication wrapper
├── Helper/                Extensions and reusable views (toast, buttons, detail rows)
├── Resources/             Assets and a named color palette
├── Fonts/                 IBM Plex Mono
└── Screens/               One folder per screen: View / ViewModel / Repository
    ├── Services (+ Banner)
    ├── FeesInquiry
    ├── BillDetails
    ├── Pin
    ├── PaymentSuccess
    └── PaymentFailure
```

Networking goes through a single `NetworkManager` that adds the common headers (`X-Request-Id`, `X-Client-Platform`, `X-User-Id`, ...), maps HTTP status codes and the API's error envelope into a typed `NetworkError`, and decodes the response. The cache fallback only kicks in for network-level errors, not for API errors.


## Tech stack

- Swift, SwiftUI, Observation
- SwiftData (offline cache)
- CryptoKit (AES-GCM), LocalAuthentication
- [Kingfisher](https://github.com/onevcat/Kingfisher) for image loading
- [Firebase iOS SDK](https://github.com/firebase/firebase-ios-sdk) (`FirebaseCore`)
- Swift Package Manager for dependencies


## Getting started

```bash
git clone https://github.com/MohamedAdel02/MomknPay.git
cd MomknPay
open MomknPay.xcodeproj
```

1. Let Xcode resolve the Swift packages (Kingfisher, Firebase).
2. Select the `MomknPay` scheme and an iOS 26.6+ simulator or device.
3. Build and run.

The API base URL is set in `APIEnvironment` (`Data/Services/Network/NetworkHelper.swift`). To run without a backend, use the mock repositories: in `MomknPay/MomknPayApp.swift`, swap in the `MockServiceRepository()` line that's already there (commented out), and set `useMockData` to `true` in `PinViewModel`.


