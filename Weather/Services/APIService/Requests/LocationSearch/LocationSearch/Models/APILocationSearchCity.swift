//
//  APILocationSearchCity.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

struct APILocationSearchCity: Decodable {
    
    let id: Int
    let location: APILocationSearchLocationDetail
    
    private enum CodingKeys: String, CodingKey {
        case id = "geoname_id"
        case location
    }
    
}
