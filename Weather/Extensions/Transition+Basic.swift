//
//  Transition+Basic.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import XCoordinator
import UIKit

extension Transition {
    
    static func alertTransition(title: String?, message: String?) -> Transition {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return .present(alert)
    }
    
    static func dialogTransition(
        title: String?,
        message: String?,
        actions: [UIAlertAction],
        style: UIAlertController.Style
    ) -> Transition {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        actions.forEach {
            alert.addAction($0)
        }
        
        return .present(alert)
    }
    
}
