//
//  AppCoordinator.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

/// From Dave Delong's(@davedelong) excellent docs:
/// The AppCoordinator is the entry point of the entire app (other than the App Delegate).
/// It provides high-level control of the various components of the app, and does small amounts
/// of data shuffling between them.
///
/// This is called a coordinator to avoid too much overloading of the word "Controller".


class AppCoordinator: NSObject, ModelDelegate, VariantListCoordinatorDelegate, UINavigationControllerDelegate {

	let model: ModelCoordinator
	let window: UIWindow
	let rootViewController: UINavigationController = {
		let nav = UINavigationController()
		// Do extra setup here, like tinting etc
		return nav
	}()

	var variantGroups: [VariantGroup] = []
	var exclusionGroups: [Set<Exclusion>] = []

	var tempVC = UIViewController()
	var listCoordinators: [VariantListCoordinator] = []
	var selectedVariationIDs: [String] = []
	var currentIndex: Int {
		return listCoordinators.count - 1
	}


	init(window: UIWindow) {
		self.window = window
		self.window.rootViewController = rootViewController
		self.window.makeKeyAndVisible()

		self.model = ModelCoordinator()
	}

	func start() {
		model.delegate = self
		rootViewController.delegate = self
		self.rootViewController.viewControllers = [tempVC]
		let loadingVC = LoadingViewController(nibName: nil, bundle: nil)
		tempVC.add(loadingVC)
		model.start()
	}

	func modelCoordinator(_ modelCoordinator: ModelCoordinator, didUpdate model: ([VariantGroup], [[Exclusion]])) {
		guard let firstVariantGroup = model.0.first else {
			return
		}

		// note: this assumes that a (groupID, variantID) pair exists only once inside of an exclusionList
		self.exclusionGroups = model.1.map(Set.init)
		(self.variantGroups, _) = model

		self.rootViewController.viewControllers = []
		let variantListCoordinator = VariantListCoordinator(variantGroup: firstVariantGroup, triggeredExclusionReasons: [:], rootViewController: rootViewController)
		self.listCoordinators = [variantListCoordinator]
		variantListCoordinator.delegate = self
		variantListCoordinator.start()
	}

	func presentNextVariantGroup() {
		let triggeredExclusions = validExclusions(groupID: variantGroups[selectedVariationIDs.count].groupID, exclusionLists: exclusionGroups, selectedIDs: selectedVariationIDs, variantGroups: variantGroups)
		let nextListCoordinator = VariantListCoordinator(variantGroup: variantGroups[selectedVariationIDs.count], triggeredExclusionReasons: triggeredExclusions, rootViewController: rootViewController)
		listCoordinators.append(nextListCoordinator)
		nextListCoordinator.delegate = self
		nextListCoordinator.start()
	}

	func coordinator(_ coordinator: VariantListCoordinator, didTapVariation variation: Variation) {
		let itemsThatTriggeredExclusions = validExclusions(groupID: variantGroups[currentIndex].groupID, exclusionLists: exclusionGroups, selectedIDs: selectedVariationIDs, variantGroups: variantGroups)
		if let reasons = itemsThatTriggeredExclusions[variation.id] {
			let problematicItems = itemNames(for: reasons, variantGroups: variantGroups)
			coordinator.rootViewController.showErrorAlert(description: Constants.Strings.Errors.itemExclusionError(with: variation.name, items: problematicItems), onTappingOkayExecute: { })
		} else {
			selectedVariationIDs.append(variation.id)
			if selectedVariationIDs.count == variantGroups.count {
				//reusing the same function we use to get the names of problematic items
				let selectedItems = Set(zip(selectedVariationIDs, variantGroups).map { Exclusion.init(groupID: $0.1.groupID, variationID: $0.0) })
				let items = itemNames(for: selectedItems, variantGroups: variantGroups)
				coordinator.rootViewController.showSuccessAlert(description: Constants.Strings.itemSelectionSuccess(with: items), onTappingOkayExecute: {
					[weak self] in
						self?.selectedVariationIDs.removeLast()
				})
			} else {
				presentNextVariantGroup()
			}
		}
	}

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		//TODO: This still kinda feels like a hack. Might refactor
		if let _ = rootViewController.topViewController as? VariantListViewController {
			self.listCoordinators = Array(listCoordinators[0..<navigationController.viewControllers.count])
			if self.listCoordinators.count == 1 {
				self.selectedVariationIDs = []
			} else {
				self.selectedVariationIDs = Array(self.selectedVariationIDs[0..<(listCoordinators.count - 1)])
			}
		}
	}

}
