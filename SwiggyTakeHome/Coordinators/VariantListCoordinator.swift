//
//  VariantCoordinator.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 24/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

protocol VariantListCoordinatorDelegate: AnyObject {
	func coordinator(_ coordinator: VariantListCoordinator, didTapVariation variation: Variation)
}

class VariantListCoordinator: VariantListViewControllerDelegate {

	let variantGroup: VariantGroup
	let triggeredExclusionReasons: [String: Set<Exclusion>]

	let rootViewController: UINavigationController
	weak var delegate: VariantListCoordinatorDelegate?

	private lazy var listViewController: VariantListViewController = {
		return VariantListViewController()
	}()

	init(variantGroup: VariantGroup, triggeredExclusionReasons: [String: Set<Exclusion>], rootViewController: UINavigationController) {
		self.triggeredExclusionReasons = triggeredExclusionReasons
		self.variantGroup = variantGroup
		self.rootViewController = rootViewController
		listViewController.delegate = self
	}

	func start() {
		let disabledVariations = Set(triggeredExclusionReasons.keys)
		listViewController.updateVariantGroup(variantGroup, andExclusions: disabledVariations)
		if let _ = rootViewController.topViewController as? VariantListViewController {
			rootViewController.pushViewController(listViewController, animated: true)
		} else {
			rootViewController.viewControllers = [listViewController]
		}
	}

	func controller(_ controller: VariantListViewController, didSelectVariationAt indexPath: IndexPath) {
		delegate?.coordinator(self, didTapVariation: variantGroup.variations[indexPath.row])
	}

}

