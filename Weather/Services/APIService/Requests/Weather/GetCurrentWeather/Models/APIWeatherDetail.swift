//
//  APIWeatherDetail.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

struct APIWeatherDetail: Decodable {
    
    let id: Int
    let main: String
    let description: String
    let icon: String
    
    var iconUrl: URL? {
        URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
    
}
