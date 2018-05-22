//
//  MockAPISession.swift
//  SwiggyTakeHomeTests
//
//  Created by Robin Malhotra on 22/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
	override func resume() { }
}

class MockAPISession: URLSession {
	let backgroundQueue = DispatchQueue.global(qos: .background)
	override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		//since there's only one request to be made, we'll directly inject the sample JSON into the response
		defer {
			backgroundQueue.async {
				let data = sampleJSONString.data(using: .utf8)!
				let httpResponse = HTTPURLResponse.init(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: [:])
				completionHandler(data, httpResponse, nil)
			}
		}
		return MockURLSessionDataTask()
	}
}
