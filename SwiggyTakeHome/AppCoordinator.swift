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
		//TODO: This still kinda feels like a hack. Must refactor
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

protocol VariantListCoordinatorDelegate: class {
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

		//TODO: In README, do mention: wouldn't it be cool if the list showed you what you selected wrong? Like if you want a regular size, but you chose cheese burst by mistake initially, the UI should tell you what you did wrong
		//TODO: This 👇
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

protocol VariantListViewControllerDelegate: class {
	func controller(_ controller: VariantListViewController,didSelectVariationAt indexPath: IndexPath)
}

class VariantListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	private var variations: [Variation] = [] {
		didSet {
			// Could do fancy diffing here (and I've written simple helpers to do this), but lets do the simple thing here 😉
			tableView.reloadData()
		}
	}
	private var excludedVariationIDs = Set<String>() {
		didSet {
			tableView.reloadData()
		}
	}

	weak var delegate: VariantListViewControllerDelegate? = nil

	let tableView = UITableView()

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.Strings.ReuseIdentifiers.variantCell)
		self.tableView.dataSource = self
		self.tableView.delegate = self

		self.view.addSubview(tableView)
		tableView.tableFooterView = UIView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.frame = self.view.bounds
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return variations.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Strings.ReuseIdentifiers.variantCell, for: indexPath)
		if excludedVariationIDs.contains(variations[indexPath.row].id) {
			cell.textLabel?.alpha = 0.5
		} else {
			cell.textLabel?.alpha = 1.0
		}
		cell.textLabel?.text = variations[indexPath.row].name
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.delegate?.controller(self, didSelectVariationAt: indexPath)
	}

	func updateVariantGroup(_ variantGroup: VariantGroup, andExclusions excludedVariationIDs: Set<String>) {
		self.title = variantGroup.name
		self.excludedVariationIDs = excludedVariationIDs
		self.variations = variantGroup.variations
	}

}
