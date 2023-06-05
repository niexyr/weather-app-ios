//
//  APIDetailedWeatherHourlyInfo.swift
//  Weather
//
//  Created by Valery Shamshin on 04.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct APIDetailedWeatherHourlyInfo: Decodable {
    
    let timestamp: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double
    let windSpeed: Double
    let windDeg: Double
    let weather: [APIWeatherDetail]
    
    private enum CodingKeys: String, CodingKey {
        case timestamp = "dt"
        case temp
        case pressure
        case humidity
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
    }
    
}
