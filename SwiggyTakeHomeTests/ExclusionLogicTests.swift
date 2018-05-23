//
//  ExclusionLogicTests.swift
//  SwiggyTakeHomeTests
//
//  Created by Robin Malhotra on 23/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import XCTest
@testable import SwiggyTakeHome

class ExclusionLogicTests: XCTestCase {
    
    func testExclusionLogic1() {
		guard let data = sampleJSONString.data(using: .utf8) else {
			XCTFail("Data from string is nil")
			return
		}

		do {
			let jsonDecoder = JSONDecoder()
			let response = try jsonDecoder.decode(APIResponse.self, from: data)
			let exlcusionLists = response.variants.exclusions.map(Set.init)
			let variantGroups = response.variants.variantGroups

			let firstSelection = ["3"]
			let firstGroupID = "2"
			let exclusions1 = validExclusions(groupID: firstGroupID, exclusionLists: exlcusionLists, selectedIDs: firstSelection, variantGroups: variantGroups)

			XCTAssertEqual(exclusions1, ["10": Set([Exclusion(groupID: "1", variationID: "3")])])

			let secondSelection = ["1", "10"]
			let secondGroupID = "3"
			let exclusions2 = validExclusions(groupID: secondGroupID, exclusionLists: exlcusionLists, selectedIDs: secondSelection, variantGroups: variantGroups)

			XCTAssertEqual(exclusions2, ["22": Set([Exclusion(groupID: "2", variationID: "10")])])
		} catch {
			XCTFail()
		}
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
