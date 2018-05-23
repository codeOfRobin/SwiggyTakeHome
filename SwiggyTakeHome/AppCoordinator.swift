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


// We're making this as general as possible
func validExclusions(groupID: String, exclusionLists: [Set<Exclusion>], selectedIDs: [String], variantGroups: [VariantGroup]) -> [String: Set<Exclusion>] {

	let selectedPairs = zip(selectedIDs, variantGroups).map{ Exclusion(groupID: $0.1.groupID, variationID: $0.0) }

	let exclusionListsWeCareAbout = exclusionLists.filter{ !$0.intersection(selectedPairs).isEmpty }

	let disabledElementsInVariantGroup = exclusionListsWeCareAbout.map { (set) -> ([String], Set<Exclusion>) in
		let disabledElements = set.filter {
			$0.groupID == groupID
		}.map {
			$0.variationID
		}

		let reasonsForDisabledElements =  set.filter { (exclusion) -> Bool in
			selectedPairs.filter{ $0.groupID == exclusion.groupID }.count > 0
		}
		return (disabledElements, reasonsForDisabledElements)
	}

	let reasonDict: [String: Set<Exclusion>] = disabledElementsInVariantGroup.reduce([:]) { (dict, arg1) in
		let (disabledIDs, reasons) = arg1
		var copy = dict
		for disabledID in disabledIDs {
			if let set = copy[disabledID] {
				copy[disabledID] = set.union(reasons)
			} else {
				copy[disabledID] = reasons
			}
		}
		return copy
	}

	return reasonDict
}

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
	var currentIndex = 0


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
		let nextListCoordinator = VariantListCoordinator(variantGroup: variantGroups[selectedVariationIDs.count], triggeredExclusionReasons: [:], rootViewController: rootViewController)
		listCoordinators.append(nextListCoordinator)
		nextListCoordinator.delegate = self
		nextListCoordinator.start()
	}

	func coordinator(_ coordinator: VariantListCoordinator, didTapItemAt indexPath: IndexPath) {
		selectedVariationIDs.append(variantGroups[currentIndex].variations[indexPath.row].id)
		presentNextVariantGroup()
	}

	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		//TODO: This still kinda feels like a hack. Must refactor
		if let _ = rootViewController.topViewController as? VariantListViewController {
			self.listCoordinators = Array(listCoordinators[0..<navigationController.viewControllers.count])
		}
	}

}

protocol VariantListCoordinatorDelegate: class {
	func coordinator(_ coordinator: VariantListCoordinator, didTapItemAt indexPath: IndexPath)
}

class VariantListCoordinator: VariantListViewControllerDelegate {

	let variantGroup: VariantGroup
	let triggeredExclusionReasons: [Int: [Variant]]

	let rootViewController: UINavigationController
	weak var delegate: VariantListCoordinatorDelegate?

	private lazy var listViewController: VariantListViewController = {
		return VariantListViewController()
	}()

	init(variantGroup: VariantGroup, triggeredExclusionReasons: [Int: [Variant]], rootViewController: UINavigationController) {
		self.triggeredExclusionReasons = triggeredExclusionReasons
		self.variantGroup = variantGroup
		self.rootViewController = rootViewController
		listViewController.delegate = self
	}

	func start() {
		listViewController.updateVariantGroup(variantGroup, triggeredExclusionReasons: [:])
		if let _ = rootViewController.topViewController as? VariantListViewController {
			rootViewController.pushViewController(listViewController, animated: true)
		} else {
			rootViewController.viewControllers = [listViewController]
		}
	}

	func controller(_ controller: VariantListViewController, didSelectVariationAt indexPath: IndexPath) {
		delegate?.coordinator(self, didTapItemAt: indexPath)
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
	private var triggeredExclusionReasons: [Int: [Variant]] = [:]

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
		cell.textLabel?.text = variations[indexPath.row].name
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		self.delegate?.controller(self, didSelectVariationAt: indexPath)
	}

	func updateVariantGroup(_ variantGroup: VariantGroup, triggeredExclusionReasons: [Int: [Variant]]) {
		self.title = variantGroup.name
		self.triggeredExclusionReasons = triggeredExclusionReasons
		self.variations = variantGroup.variations
	}

}
