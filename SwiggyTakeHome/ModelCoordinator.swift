//
//  ModelCoordinator.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

protocol ModelDelegate: class {
	func modelCoordinator(_ model: ModelCoordinator, didUpdate variant: Variant)
}

class ModelCoordinator {
	private var variantGroups: [VariantGroup] = []
	private var exclusions: [[Exclusion]] = []

	func start() {
	}
}
