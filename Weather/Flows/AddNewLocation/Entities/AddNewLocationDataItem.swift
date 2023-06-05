//
//  AddNewLocationDataItem.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import RxDataSources

enum AddNewLocationDataItem: IdentifiableType, Equatable {
    
    case location(model: LocationModel)
    
}

extension AddNewLocationDataItem {
    
    var identity: String {
        switch self {
        case let .location(model): return model.locationId
        }
    }
    
}
