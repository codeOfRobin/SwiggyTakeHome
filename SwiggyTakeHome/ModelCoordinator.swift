//
//  ModelCoordinator.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

//TODO: Remove Mock files like SampleJSON from Target before submitting

protocol ModelDelegate: class {
	func modelCoordinator(_ modelCoordinator: ModelCoordinator, didUpdate model: ([VariantGroup], [[Exclusion]]))
}

class ModelCoordinator {
	private var model: ([VariantGroup], [[Exclusion]])? = nil {
		didSet { notifyDelegate() }
	}

	weak var delegate: ModelDelegate? = nil

	let apiClient: APIClient

	init() {
		//TODO: Fix this
//		self.apiClient = apiClient
		self.apiClient = APIClient.init(session: MockAPISession())
	}

	func start() {
		apiClient.getVariants(forBinWithID: Constants.Strings.binID) { (result) in
			switch result {
			case .success(let response):
				self.model = (response.variants.variantGroups, response.variants.exclusions)
			case .failure(let error):
				print(error.localizedDescription)
				//TODO: handle this
			}
		}
	}

	func notifyDelegate() {
		guard let model = model else {
			return
		}
		delegate?.modelCoordinator(self, didUpdate: model)
	}
}
