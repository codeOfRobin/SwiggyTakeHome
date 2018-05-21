//
//  ErrorViewController.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

	let errorLabel = UILabel()
	let insets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)

	override func viewDidLoad() {
		super.viewDidLoad()

		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(errorLabel)

		self.view.backgroundColor = .white
		errorLabel.numberOfLines = 0

		NSLayoutConstraint.activate([
			errorLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: insets.left),
			errorLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -insets.right),
			errorLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
			])
		// Do any additional setup after loading the view.
	}

	func configure(text: String) {
		errorLabel.text = text
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}
