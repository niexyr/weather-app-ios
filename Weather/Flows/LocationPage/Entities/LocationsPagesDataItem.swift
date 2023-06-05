//
//  LocationsPagesDataItem.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import RxDataSources
import Foundation

enum LocationsPagesDataItem: IdentifiableType, Equatable {
    
    case preview(location: LocationModel, temperature: Double?, iconUrl: URL?, weatherDescription: String?)
    
}

extension LocationsPagesDataItem {
    
    var identity: String {
        switch self {
        case let .preview(location, _, _, _): return location.locationId
        }
    }
    
}
