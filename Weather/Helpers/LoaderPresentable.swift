//
//  LoaderPresentable.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import JGProgressHUD

protocol LoaderPresentable: UIViewController {
    
    var loader: JGProgressHUD? { get set }
    var loaderContainer: UIView { get }
    var loaderStyle: JGProgressHUDStyle { get }
    
    func updateLoader(isEnabled: Bool, detailText: String?)
    
}

extension LoaderPresentable {
    
    // MARK: По умолчанию - берется вся view у viewController
    var loaderContainer: UIView {
        view
    }
    
    // MARK: По умолчанию используется белая крутилка на черном фоне
    var loaderStyle: JGProgressHUDStyle {
        .dark
    }
    
    // MARK: Имплементация по умолчанию (юзается на нескольких экранах щас)
    func updateLoader(isEnabled: Bool, detailText: String?) {
        guard isEnabled else {
            loader?.dismiss()
            return
        }
        
        guard let loader = loader else {
            let loader = JGProgressHUD(style: loaderStyle)
            loader.detailTextLabel.text = detailText
            loader.parallaxMode = .alwaysOff
            loader.show(in: loaderContainer)
            
            self.loader = loader
            return
        }
        
        loader.detailTextLabel.text = detailText
        
        if !loader.isVisible {
            loader.show(in: loaderContainer)
        }
    }
    
}
