//
//  Constants.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 22/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import Foundation

enum Constants {
	enum Strings {
		static let binID = "3b0u2"

		enum Errors {
			static let cellDequeueing = NSLocalizedString("UITableView couldn't be dequeued. Obviously something went really wrong here", comment: "")
			static let viewControllerInitialization = NSLocalizedString("UIViewController could not be initialized", comment: "")
			static let dataIsNil = NSLocalizedString("Data receieved in request was nil", comment: "")
			static let clientSideError = NSLocalizedString("Whoops, looks like something failed on our end. We'll look into it 😅", comment: "")
		}
	}
}
