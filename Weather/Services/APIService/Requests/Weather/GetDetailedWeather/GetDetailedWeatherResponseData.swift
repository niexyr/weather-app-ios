//
//  GetDetailedWeatherResponseData.swift
//  Weather
//
//  Created by Valery Shamshin on 04.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct GetDetailedWeatherResponseData: Decodable {
    
    let timezone: String
    let current: APIDetailedWeatherCurrentInfo
    let hourly: [APIDetailedWeatherHourlyInfo]
    let daily: [APIDetailedWeatherDailyInfo]
    
}
