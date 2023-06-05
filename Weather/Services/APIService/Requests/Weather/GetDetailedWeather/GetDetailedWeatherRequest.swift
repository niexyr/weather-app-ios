//
//  GetDetailedWeatherRequest.swift
//  Weather
//
//  Created by Valery Shamshin on 04.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct GetDetailedWeatherRequest {
    
    let latitude: Double
    let longitude: Double
    
}

extension GetDetailedWeatherRequest {
    
    var requestParameters: [String: Any] {
        [
            "lat": latitude,
            "lon": longitude,
            "appid": Constants.openWeatherMapAPIKey,
            "units": "metric",
            "lang": "ru",
            "exclude": "minutely,alerts"
        ]
    }
    
}
