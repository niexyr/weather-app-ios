//
//  GetCurrentWeatherResponseData.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct GetCurrentWeatherResponseData: Decodable {
    
    let count: Int
    let list: [APIWeatherSummary]
    
    private enum CodingKeys: String, CodingKey {
        case count = "cnt"
        case list
    }
    
}
