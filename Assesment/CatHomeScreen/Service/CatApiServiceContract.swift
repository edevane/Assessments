//
//  ApiServiceContract.swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation
import RxSwift

protocol CatApiServiceContract {
    func getData(limit: Int?) async throws -> [Cat]
    func getBreedData(of id: String) async throws -> Cat?
    func searchData(with name: String) -> Observable<[Cat]>
}
