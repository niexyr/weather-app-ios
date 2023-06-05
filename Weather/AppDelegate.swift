//
//  AppDelegate.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit
import XCoordinator

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private lazy var mainWindow = UIWindow()
    
    private let router = AppCoordinator().strongRouter
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        router.setRoot(for: mainWindow)
        
        return true
    }

}
