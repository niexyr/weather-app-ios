//
//  LocationSearchResponseData.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct LocationSearchResponseData: Decodable {
    
    let embeddedSearchResults: APILocationSearchEmbeddedResults
    
    private enum CodingKeys: String, CodingKey {
        case embeddedSearchResults = "_embedded"
    }
    
}
