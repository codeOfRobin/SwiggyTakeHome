//
//  AppDelegate.swift
//  SwiggyTakeHome
//
//  Created by Robin Malhotra on 20/05/18.
//  Copyright © 2018 Robin Malhotra. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	// Wish Swift had delayed instantiation ☹️
	var coordinator: AppCoordinator?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.

		window = UIWindow(frame: UIScreen.main.bounds)
		self.coordinator = AppCoordinator(window: window!)

		self.coordinator?.start()

		return true
	}

}

