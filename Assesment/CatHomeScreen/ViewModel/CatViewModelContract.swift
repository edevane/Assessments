//
//  CatViewModelContract.swift
//  Assesment
//
//  Created by Edevane Tan on 20/12/2024.
//

import Foundation
import RxSwift

protocol CatViewModelContract {
    var searchResult: [Cat] { get set }
    var featuredCats: Set<Cat> { get set }
    var favouritedCats: Set<Cat> { get set }
    func fetchCat() async
    func searchBreed(for term: String) -> Observable<[Cat]>
    func populateFeaturedCats()
    func populateFavouritedCats()
    func favouriteCatData(for data: Animal)
    func removeFavourite(for data: Animal)
}
