//
//  Animal.swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation
import RealmSwift

protocol Animal {
    var id: String { get }
    var name: String { get }
    var origin: String? { get }
    var breedDescription: String? { get }
    var temperament: [String]? { get }
    var lifespan: String? { get }
    var wikipediaURL: String? { get }
    var referencePhotoID: String? { get }
    var image: Data? { get set }
}
