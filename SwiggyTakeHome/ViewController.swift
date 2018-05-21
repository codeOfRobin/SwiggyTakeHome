//
//  ViewController.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 20/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

extension VariantSelectionViewController.State: Equatable {}
internal func == (lhs: VariantSelectionViewController.State, rhs: VariantSelectionViewController.State) -> Bool {
	switch (lhs, rhs) {
	case (.loading, .loading):
		return true
	case (.error(let error1), .error(let error2)):
		// We could make this more efficient by doing a deeper comparison, but I'm gonna be lazy here 😛
		return error1.localizedDescription == error2.localizedDescription
	case (.loaded, .loaded):
		return true
	default: return false
	}
}


class VariantSelectionViewController: UIViewController {

	lazy var loadingVC = LoadingViewController(nibName: nil, bundle: nil)
	lazy var errorVC = ErrorViewController(nibName: nil, bundle: nil)

	enum State {
		case loading(LoadingViewController)
		case error(Error)
		case loaded
	}

	var state: State = .loaded {
		didSet {
			guard oldValue != state else {
				return
			}

			switch oldValue {
			case .loading:
				loadingVC.remove()
			case .error:
				errorVC.remove()
			default:
				break
			}

			switch state {
			case .loading:
				self.add(loadingVC)
			case .error(let error):
				self.errorVC.configure(text: error.localizedDescription)
				self.add(errorVC)
			default:
				return
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

}

