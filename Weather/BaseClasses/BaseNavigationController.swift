//
//  BaseNavigationController.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
    
}
