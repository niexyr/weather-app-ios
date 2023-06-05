//
//  GetCurrentWeatherRequest.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct GetCurrentWeatherRequest {
    
    let locationIds: [String]
    
}

extension GetCurrentWeatherRequest {
    
    var requestParameters: [String: Any] {
        [
            "id": locationIds.joined(separator: ","),
            "appid": Constants.openWeatherMapAPIKey,
            "units": "metric",
            "lang": "ru"
        ]
    }
    
}
