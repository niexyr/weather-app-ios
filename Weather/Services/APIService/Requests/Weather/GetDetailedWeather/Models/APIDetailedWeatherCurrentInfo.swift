//
//  APIDetailedWeatherCurrent.swift
//  Weather
//
//  Created by Valery Shamshin on 04.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct APIDetailedWeatherCurrentInfo: Decodable {
    
    let temp: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double
    let windSpeed: Double
    let windDeg: Double
    let weather: [APIWeatherDetail]
    let visibility: Double
    let sunrise: Int
    let sunset: Int
    
    private enum CodingKeys: String, CodingKey {
        case temp
        case pressure
        case humidity
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
        case visibility
        case sunrise
        case sunset
    }
    
}
