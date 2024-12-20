//
//  CatAPIService.swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation
import RxSwift

class CatApiService: CatApiServiceContract {

    let networkManager: NetworkManager
    let jsonDecoder = JSONDecoder()

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getData(limit: Int? = nil) async throws -> [Cat] {
        let queryDictionary: [String: String] = {
            if let limit {
                return [ApiQueryParameter.limit.rawValue: "\(limit)"]
            } else {
                return [:]
            }
        }()

        guard let data = try await networkManager.fetchData(from: .breeds,
                                                            path: nil,
                                                            using: queryDictionary) else {
            return []
        }

        var cats = try jsonDecoder.decode([Cat].self, from: data)
        cats = try await self.resolveCatImages(of: cats)
        return cats
    }

    func getBreedData(of id: String) async throws -> Cat? {
        guard let data = try await networkManager.fetchData(from: .breeds,
                                                            path: "/\(id)",
                                                            using: nil) else {
            return nil
        }

        return try jsonDecoder.decode(Cat.self, from: data)
    }

    func searchData(with name: String) -> Observable<[Cat]> {
        let queryDictionary: [String: String] = {
            return [ApiQueryParameter.keyword.rawValue: name]
        }()

        return networkManager.fetchData(from: .breedSearch, path: nil, using: queryDictionary)
            .map { [weak self] data in
                guard let self else {
                    return []
                }
                return try self.jsonDecoder.decode([Cat].self, from: data)
            }
    }

    private func resolveCatImages(of data: [Cat]) async throws -> [Cat] {
        var catsData = data
        for index in (0...catsData.count - 1) {
            if let photoID = catsData[index].referencePhotoID {
                catsData[index].image = try await NetworkManager.fetchImage(of: photoID)
            }
        }

        return catsData
    }
}
