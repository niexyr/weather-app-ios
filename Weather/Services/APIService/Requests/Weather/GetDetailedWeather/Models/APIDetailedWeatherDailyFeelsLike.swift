//
//  APIDetailedWeatherDailyFeelsLike.swift
//  Weather
//
//  Created by Valery Shamshin on 04.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct APIDetailedWeatherDailyFeelsLike: Decodable {
    
    let day: Double
    let night: Double
    let evening: Double
    let morning: Double
    
    private enum CodingKeys: String, CodingKey {
        case day
        case night
        case evening = "eve"
        case morning = "morn"
    }
    
}
