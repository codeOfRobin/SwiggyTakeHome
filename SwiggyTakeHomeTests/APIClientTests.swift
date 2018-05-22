//
//  APIClientTests.swift
//  SwiggyTakeHomeTests
//
//  Created by Robin Malhotra on 22/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import XCTest
@testable import SwiggyTakeHome

class APIClientTests: XCTestCase {

	let requestBuilder = APIRequestBuilder()
	let mockedSession = MockAPISession()
	var client: APIClient!

    override func setUp() {
        super.setUp()
		client = APIClient(session: mockedSession)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequest() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
		let request = requestBuilder.request(forBinWithID: "12345")
		XCTAssertEqual(request?.url?.absoluteString, "https://api.myjson.com/bins/12345")
    }

	func testWithFakedSession() {
		let clientExpectation = expectation(description: "Correct Request + Parsing")
		client.getVariants(forBinWithID: "12345") { (result) in
			if case .success(let response) = result {
				XCTAssertTrue(response.variants.exclusions.count > 0)
				clientExpectation.fulfill()
			}
		}
		waitForExpectations(timeout: 10.0, handler: nil)
	}
    
}
