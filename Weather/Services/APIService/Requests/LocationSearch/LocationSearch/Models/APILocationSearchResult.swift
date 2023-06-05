//
//  APILocationSearchResults.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

struct APILocationSearchResult: Decodable {
    
    let embeddedCity: APILocationSearchEmbeddedCity
    let matchingAlternateNames: [APILocationSearchAlternateName]
    let matchingFullName: String
    
    private enum CodingKeys: String, CodingKey {
        case embeddedCity = "_embedded"
        case matchingAlternateNames = "matching_alternate_names"
        case matchingFullName = "matching_full_name"
    }
    
    var id: String {
        embeddedCity.city.id.string
    }
    
    var detailedName: String? {
        let components = matchingFullName.components(separatedBy: ", ")
            
        switch components.count {
        case 0:
            return nil
            
        case 1:
            return components[0]
            
        default:
            let city = components.first
            let country = components.last?.prefix { $0 != "(" }.trimmingCharacters(in: .whitespaces)
            
            return [city, country]
                .compactMap { $0 }
                .joined(separator: ", ")
        }
    }
    
}
