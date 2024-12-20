//
//  CatModelTest.swift
//  AssesmentTests
//
//  Created by Edevane Tan on 17/12/2024.
//

import Foundation
import Testing
@testable import Assesment

struct CatModelTest {

    let sampleJSON: Data? = {
        guard let data = Bundle(identifier: "com.edevane.AssesmentTests")?
            .url(forResource: "Cat", withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: data)
    }()

    @Test func decodeCatJSON_Successful() {
        guard let sampleJSON else {
            Issue.record("Failed to read Cat.json file")
            return
        }

        let decodedData = try? JSONDecoder().decode([Cat].self, from: sampleJSON)
        #expect(decodedData?.count == 10)
        #expect(decodedData?.contains(where: { $0.name == "Australian Mist" }) == true)
    }
}
