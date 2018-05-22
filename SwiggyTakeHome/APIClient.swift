//
//  APIClient.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 22/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

enum Result<T> {
	case success(T)
	case failure(Error)
}

/// In the real world, we'd probably loading Variant Categories separately depending on an API Call probably, so it's good to separate a `Request Builder` class that is just responsible for building requests and is, as a consequence, is also testable
class APIRequestBuilder {
	enum Constants {
		static let host = "api.myjson.com"
		static let scheme = "https"
		static let binsPath = "bins"
	}

	func request(forBinWithID bin: String) -> URLRequest? {
		var components = URLComponents()
		components.scheme = Constants.scheme
		components.host = Constants.host

		let path = "/\(Constants.binsPath)/\(bin)"
		components.path = path

		guard let url = components.url else {
			fatalError("Can't generate URL")
		}

		//no other setup needed, no httpBody, httpMethod is "GET" by default
		return URLRequest(url: url)
	}
}

class APIClient {
	let session: URLSession
	let requestBuilder = APIRequestBuilder()

	enum APIError: Error {
		case requestCreationFailed
		case urlSessionError(NSError)
		case dataIsNil
		case decodingError(DecodingError)
		case invalidResponse(Data, HTTPURLResponse)

		var localizedDescription: String {
			switch self {
			case .dataIsNil:
				return Constants.Strings.Errors.dataIsNil
			case .decodingError, .requestCreationFailed, .invalidResponse:
				return Constants.Strings.Errors.clientSideError
			case .urlSessionError(let nsErrror):
				return nsErrror.localizedDescription
			}
		}
	}

	init(session: URLSession) {
		self.session = session
	}

	@discardableResult func getVariants(forBinWithID binID: String, completion: @escaping ((Result<APIResponse>) -> Void)) -> URLSessionDataTask? {
		guard let request = requestBuilder.request(forBinWithID: binID) else {
			completion(.failure(APIError.requestCreationFailed))
			return nil
		}
		let task = performRequest(request: request, for: APIResponse.self) { (result) in
			completion(result)
		}
		return task
	}

	@discardableResult private func performRequest<T: Decodable>(request: URLRequest, for type: T.Type, onComplete completion: @escaping ((Result<T>) -> Void)) -> URLSessionDataTask {
		let task = session.dataTask(with: request) { (data, response, error) in
			if let nsError = error as NSError?, nsError.domain == NSURLErrorDomain {
				DispatchQueue.main.sync {
					completion(.failure(APIError.urlSessionError(nsError)))
				}
			}

			guard let data = data, let httpResponse = response as? HTTPURLResponse else {
				DispatchQueue.main.sync {
					completion(.failure(APIError.dataIsNil))
				}
				return
			}

			let jsonDecoder = JSONDecoder()

			guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
				completion(.failure(APIError.invalidResponse(data, httpResponse)))
				return
			}

			do {
				let value = try jsonDecoder.decode(T.self, from: data)
				DispatchQueue.main.sync {
					completion(.success(value))
				}
			} catch {
				if let decodingError = error as? DecodingError {
					DispatchQueue.main.sync {
						completion(.failure(APIError.decodingError(decodingError)))
					}
				} else {
					// You could make this fail as a `randomError` or something, but I don't like having undefined cases in my API. Better to fail first and fail fast usually
					fatalError()
				}
			}
		}

		task.resume()
		return task
	}

}
