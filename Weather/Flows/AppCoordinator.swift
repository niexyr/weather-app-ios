//
//  AppCoordinator.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import CoreLocation
import UIKit
import XCoordinator
import RxSwift
import RxCocoa
import Realm
import RealmSwift

enum AppRoute: Route {
    
    case locationPages
    case addNewLocation(delegate: AddNewLocationViewModelDelegate)
    
    case alert(title: String?, message: String?)
    case dialog(title: String?, message: String?, actions: [UIAlertAction], style: UIAlertController.Style)
    
    case dismiss
    case pop
    
}

class AppCoordinator: NavigationCoordinator<AppRoute> {
    
    private let disposeBag = DisposeBag()
    
    private let apiWrapper = APIWrapper()
    private let realmService = RealmService()
    private var locationService = LocationService()
    
    init() {
        super.init(rootViewController: BaseNavigationController(), initialRoute: .locationPages)
        
        rootViewController.setNavigationBarHidden(true, animated: false)
    }
    
    override func prepareTransition(for route: AppRoute) -> NavigationTransition {
        switch route {
            
        case .locationPages:
            let vm = LocationsPagesViewModel(
                apiWrapper: apiWrapper,
                realmService: realmService,
                router: weakRouter,
                locationService: locationService
            )
            
            let vc = LocationsPagesViewController(viewModel: vm)
            return .set([vc])
            
        case let .addNewLocation(delegate):
            let vm = AddNewLocationViewModel(
                apiWrapper: apiWrapper,
                realmService: realmService,
                delegate: delegate,
                router: weakRouter
            )
            
            let vc = AddNewLocationViewController(viewModel: vm)
            return .present(vc)
            
        case let .alert(title, message):
            return .alertTransition(title: title, message: message)
            
        case let .dialog(title, message, actions, style):
            return .dialogTransition(title: title, message: message, actions: actions, style: style)
            
        case .dismiss:
            return .dismiss()
            
        case .pop:
            return .pop()
        }
    }
    
}
