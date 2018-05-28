//
//  UIViewController+Children.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 21/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

extension UIViewController {
	func add(_ child: UIViewController) {
		addChildViewController(child)
		view.addSubview(child.view)
		child.didMove(toParentViewController: self)
	}

	func remove() {
		guard parent != nil else {
			return
		}

		willMove(toParentViewController: nil)
		removeFromParentViewController()
		view.removeFromSuperview()
	}
}
