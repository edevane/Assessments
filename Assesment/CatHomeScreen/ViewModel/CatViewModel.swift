//
//  CatViewModel.swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation
import RxSwift
import RealmSwift

class CatViewModel: CatViewModelContract {

    let realm = try? Realm()
    let catService: CatApiServiceContract
    let defaultLimit = 10
    var dataSource = [Cat]()
    var searchResult = [Cat]()
    var featuredCats = Set<Cat>()
    var favouritedCats = Set<Cat>()

    init(catService: CatApiServiceContract) {
        self.catService = catService
    }

    public func fetchCat() async {
        if let cats = try? await self.catService.getData(limit: defaultLimit) {
            self.dataSource = cats
        }
    }

    public func searchBreed(for term: String) -> Observable<[Cat]> {
        return self.catService.searchData(with: term)
    }

    public func populateFeaturedCats() {
        if dataSource.count > 0 {
            repeat {
                if let randomCatData = dataSource.randomElement() {
                    featuredCats.insert(randomCatData)
                }
            } while featuredCats.count < 5
        }
    }

    public func populateFavouritedCats() {
        self.favouritedCats.removeAll()
        if let ids = realm?.objects(FavouritedCat.self).map({ $0.id }) {
            for id in ids {
                if let result = dataSource.filter({ $0.id == id }).first {
                    self.favouritedCats.insert(result)
                } else {
                    Task {
                        if let catData = try await catService.getBreedData(of: id) {
                            self.favouritedCats.insert(catData)
                        }
                    }
                }
            }
        }
    }

    public func favouriteCatData(for data: Animal) {
        do {
            let id = data.id
            let newFavouriteCatRecord = FavouritedCat()
            newFavouriteCatRecord.id = id
            try realm?.write {
                realm?.add(newFavouriteCatRecord)
            }
        } catch {
            print("An error occurred while saving: \(error)")
        }
    }

    public func removeFavourite(for data: Animal) {
        if let matchedRecord = realm?.objects(FavouritedCat.self)
            .filter({ $0.id == data.id }).first {
            do {
                try realm?.write {
                    realm?.delete(matchedRecord)
                }

                self.populateFavouritedCats()
            } catch {
                print("An error occurred while deleting: \(error)")
            }
        }
    }
}
