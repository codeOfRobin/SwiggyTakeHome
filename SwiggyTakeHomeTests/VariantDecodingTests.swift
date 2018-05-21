
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
		let jsonDecoder = JSONDecoder()

		guard let data = sampleJSONString.data(using: .utf8) else {
			XCTFail("Data from string is nil")
			return
		}

		do {
			let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
			print(jsonObject)
			let response = try jsonDecoder.decode(APIResponse.self, from: data)
//			XCTAssert(response.variants.count == 1)
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
