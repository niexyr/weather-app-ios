//
//  APIEmbeddedCityItem.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct APILocationSearchEmbeddedCity: Decodable {
    
    let city: APILocationSearchCity
    
    private enum CodingKeys: String, CodingKey {
        case city = "city:item"
    }
    
}
