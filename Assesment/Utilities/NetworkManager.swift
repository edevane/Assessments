//
//  Networking .swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation
import Combine
import RxSwift

enum ApiEndpoint: String {
    case images = "/images"
    case imageSearch = "/images/search"
    case breeds = "/breeds"
    case breedSearch = "/breeds/search"
}

enum ApiQueryParameter: String {
    case keyword = "q"
    case order
    case limit
    case page
}

enum ApiError: Error {
    case invalidURL
    case networkError
}

class NetworkManager {
    private let session = URLSession.shared
    private let baseURL = "https://api.thecatapi.com"
    private let version = "/v1"

    func fetchData(from endpoint: ApiEndpoint,
                   path pathParameter: String?,
                   using query: [String: String]?) async throws -> Data? {
        var url = "\(baseURL + version + endpoint.rawValue)"
        if let pathParameter {
            url.append(pathParameter)
        }

        guard var urlComponent = URLComponents(string: url) else {
            throw ApiError.invalidURL
        }

        if let query {
            urlComponent.queryItems = self.constructQueryItems(with: query)
        }

        let (data, _) = try await session.data(from: urlComponent.url!)
        return data
    }

    func fetchData(from endpoint: ApiEndpoint,
                   path pathParameter: String?,
                   using query: [String: String]?) -> Observable<Data> {
        var url = "\(baseURL + version + endpoint.rawValue)"
        if let pathParameter {
            url.append(pathParameter)
        }

        guard var urlComponent = URLComponents(string: url) else {
            return .error(ApiError.networkError)
        }

        if let query {
            urlComponent.queryItems = self.constructQueryItems(with: query)
        }

        return session.rx.data(request: URLRequest(url: urlComponent.url!))
    }

    private func constructQueryItems(with query: [String: String]) -> [URLQueryItem] {
        var queries = [URLQueryItem]()
        for item in query {
            queries.append(URLQueryItem(name: item.key, value: item.value))
        }
        return queries
    }

    static func fetchImage(of id: String) async throws -> Data? {
        let baseURL = "https://cdn2.thecatapi.com/images/"
        let fileExtension = ".jpg"
        let url = baseURL + id + fileExtension

        guard let url = URL(string: url) else {
            throw ApiError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
