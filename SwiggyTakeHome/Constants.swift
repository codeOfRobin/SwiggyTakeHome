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
		static let error = NSLocalizedString("Error", comment: "")
		static let success = NSLocalizedString("🎉", comment: "")
		static let okay = NSLocalizedString("Okay", comment: "")

		enum Errors {
			static let cellDequeueing = NSLocalizedString("UITableView couldn't be dequeued. Obviously something went really wrong here", comment: "")
			static let viewControllerInitialization = NSLocalizedString("UIViewController could not be initialized", comment: "")
			static let dataIsNil = NSLocalizedString("Data receieved in request was nil", comment: "")
			static let clientSideError = NSLocalizedString("Whoops, looks like something failed on our end. We'll look into it 😅", comment: "")
			static func itemExclusionError(with option: String, items: [String]) -> String {
				return NSLocalizedString("Sorry, you can't select the option \(option) because you previously selected the following: \(items.joined(separator: ", "))", comment: "")
			}
		}

		static func itemSelectionSuccess(with items: [String]) -> String {
			return NSLocalizedString("Congrats! You've chosen a dish with the following variations: \(items.joined(separator: ", "))", comment: "")
		}

		enum ReuseIdentifiers {
			static let variantCell = "VariantCell"
		}
	}
}
