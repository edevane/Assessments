//
//  CatModel.swift
//  Assesment
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation

struct Cat: Animal, Decodable, Hashable {
    public private(set) var id: String
    public private(set) var name: String
    public private(set) var origin: String?
    public private(set) var breedDescription: String?
    public private(set) var temperament: [String]?
    public private(set) var lifespan: String?
    public private(set) var wikipediaURL: String?
    public private(set) var referencePhotoID: String?
    public var image: Data?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case origin
        case breedDescription = "description"
        case temperament
        case lifespan = "life_span"
        case wikipediaURL = "wikipedia_url"
        case referencePhotoID = "reference_image_id"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.origin = try container.decodeIfPresent(String.self, forKey: .origin)
        self.breedDescription = try container.decodeIfPresent(String.self, forKey: .breedDescription)
        self.lifespan = try container.decodeIfPresent(String.self, forKey: .lifespan)
        self.wikipediaURL = try container.decodeIfPresent(String.self, forKey: .wikipediaURL)
        self.referencePhotoID = try container.decodeIfPresent(String.self, forKey: .referencePhotoID)
        if let temperamentString = try container.decodeIfPresent(String.self, forKey: .temperament) {
            self.temperament = temperamentString
                .components(separatedBy: ", ")
                .map { return $0.uppercased() }
        }
    }

    init(id: String,
         name: String,
         origin: String?,
         breedDescription: String?,
         temperament: [String]?,
         lifespan: String?,
         wikipediaURL: String?,
         referencePhotoID: String?) {
        self.id = id
        self.name = name
        self.origin = origin
        self.breedDescription = breedDescription
        self.lifespan = lifespan
        self.wikipediaURL = wikipediaURL
        self.referencePhotoID = referencePhotoID
        self.temperament = temperament
    }
}
