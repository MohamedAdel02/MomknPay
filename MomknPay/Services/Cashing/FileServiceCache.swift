//
//  FileServiceCache.swift
//  MomknPay
//
//  Created by Mohamed Adel on 04/10/2026.
//

import Foundation

protocol ServiceCaching {
    func load() -> ServicesResponse?
    func save(_ response: ServicesResponse)
}

class FileServiceCache: ServiceCaching {

    private let url: URL

    init(fileName: String = "services-cache.json") {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        url = directory.appendingPathComponent(fileName)
    }

    func load() -> ServicesResponse? {
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder.api.decode(ServicesResponse.self, from: data)
    }

    func save(_ response: ServicesResponse) {
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(response) else { return }
        try? data.write(to: url, options: .atomic)
    }
}
