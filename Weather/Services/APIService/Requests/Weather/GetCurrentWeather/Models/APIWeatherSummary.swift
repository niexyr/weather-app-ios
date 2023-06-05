//
//  APIWeatherSummary.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct APIWeatherSummary: Decodable {
    
    let id: Int
    let name: String
    let coord: APIWeatherCoord
    let weather: [APIWeatherDetail]
    let main: APIWeatherMain
    let wind: APIWeatherWind
    
}
