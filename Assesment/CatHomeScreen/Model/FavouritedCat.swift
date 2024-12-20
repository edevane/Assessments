//
//  FavouritedCat.swift
//  Assesment
//
//  Created by Edevane Tan on 20/12/2024.
//

import Foundation
import RealmSwift

class FavouritedCat: Object {
    @Persisted(primaryKey: true) public var id: String = ""
}
