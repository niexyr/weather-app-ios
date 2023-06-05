//
//  APILocationSearchLocationDetail.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct APILocationSearchLocationDetail: Decodable {
    
    let coordinates: APILocationSearchCoordinates
    
    private enum CodingKeys: String, CodingKey {
        case coordinates = "latlon"
    }
    
}
