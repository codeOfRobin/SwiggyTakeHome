//
//  LoadingViewController.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

	lazy var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

	override func viewDidLoad() {
		super.viewDidLoad()

		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(activityIndicator)

		self.view.backgroundColor = .white

		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
			])
		// Do any additional setup after loading the view.
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.activityIndicator.stopAnimating()
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
			self?.activityIndicator.startAnimating()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}


