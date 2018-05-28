//
//  VariantListViewController.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 24/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

protocol VariantListViewControllerDelegate: AnyObject {
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
