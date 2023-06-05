//
//  AddNewLocationSectionModel.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import RxDataSources

struct AddNewLocationSectionModel: AnimatableSectionModelType {
    
    let identity: String
    
    var items: [AddNewLocationDataItem]
    
}

extension AddNewLocationSectionModel: SectionModelType {
    
    init(original: AddNewLocationSectionModel, items: [AddNewLocationDataItem]) {
        self = original
        self.items = items
    }
    
}
