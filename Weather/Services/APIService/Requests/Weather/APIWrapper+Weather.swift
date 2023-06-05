//
//  APIWrapper+Weather.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxMoya

extension APIWrapper {
    
    func getCurrentWeather(locationIds: [String]) -> Single<GetCurrentWeatherResponseData?> {
        guard isReachable else {
            return .error(NSError.APIWrapperError.noConnectionError)
        }
        
        let request = GetCurrentWeatherRequest(locationIds: locationIds)
        
        return provider.rx
            .request(.getCurrentWeather(request: request))
            .convertNoConnectionError()
            .mapAsDefaultResponse()
    }
    
    func getDetailedWeather(latitude: Double, longitude: Double) -> Single<GetDetailedWeatherResponseData?> {
        guard isReachable else {
            return .error(NSError.APIWrapperError.noConnectionError)
        }
        
        let request = GetDetailedWeatherRequest(latitude: latitude, longitude: longitude)
        
        return provider.rx
            .request(.getDetailedWeather(request: request))
            .convertNoConnectionError()
            .mapAsDefaultResponse()
    }
    
}
