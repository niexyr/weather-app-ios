//
//  LocationsPagesSectionModel.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import RxDataSources

struct LocationsPagesSectionModel: AnimatableSectionModelType {
    
    let identity: String
    
    var items: [LocationsPagesDataItem]
    
}

extension LocationsPagesSectionModel: SectionModelType {
    
    init(original: LocationsPagesSectionModel, items: [LocationsPagesDataItem]) {
        self = original
        self.items = items
    }
    
}
