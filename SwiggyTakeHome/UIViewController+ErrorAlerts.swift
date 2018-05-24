//
//  UIViewController+ErrorAlerts.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 23/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

extension UIViewController {
	func showErrorAlert(description: String, onTappingOkayExecute completionHandler: @escaping () -> Void) {
		let alertControler = UIAlertController.init(title: Constants.Strings.error, message: description, preferredStyle: .alert)
		alertControler.addAction(UIAlertAction.init(title: Constants.Strings.okay, style: .default, handler: { (action) in
			completionHandler()
			alertControler.dismiss(animated: true, completion: nil)
		}))
		self.present(alertControler, animated: true, completion: nil)
	}

	func showSuccessAlert(description: String, onTappingOkayExecute completionHandler: @escaping () -> Void) {
		let alertController = UIAlertController(title: Constants.Strings.success, message: description, preferredStyle: .alert)
		alertController.addAction(UIAlertAction.init(title: Constants.Strings.okay, style: .default, handler: { (action) in
			completionHandler()
			alertController.dismiss(animated: true, completion: nil)
		}))
		self.present(alertController, animated: true, completion: nil)
	}
}
