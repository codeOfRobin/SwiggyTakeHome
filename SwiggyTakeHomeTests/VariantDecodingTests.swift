
//
//  VariantDecodingTests.swift
//  SwiggyTakeHomeTests
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import XCTest
@testable import SwiggyTakeHome

class VariantDecodingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

		guard let data = sampleJSONString.data(using: .utf8) else {
			XCTFail("Data from string is nil")
			return
		}

		do {
			let jsonDecoder = JSONDecoder()
			let response = try jsonDecoder.decode(APIResponse.self, from: data)

			let variants = response.variants
			let exclusions = variants.exclusions
			let groups = variants.variantGroups
			XCTAssert(exclusions.count == 2)
			XCTAssert(exclusions[0].count == 2)
			XCTAssert(exclusions[1].count == 2)
			XCTAssert(groups.count == 3)
			XCTAssert(groups[0].variations.count == 3)
			XCTAssert(groups[0].variations[0].name == "Thin")
		} catch {
			print(error as! DecodingError)
			XCTFail()
		}
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecoding() {

    }
    
}
