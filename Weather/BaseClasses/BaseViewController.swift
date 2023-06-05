//
//  BaseViewController.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    var shouldHideNavigationBar = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(shouldHideNavigationBar, animated: true)
    }
    
}
