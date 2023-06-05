//
//  LocationSearchRequest.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct LocationSearchRequest {
    
    let text: String
    
}

extension LocationSearchRequest {
    
    var requestParameters: [String: Any] {
        ["search": text, "embed": "city:search-results/city:item"]
    }
    
}
