//
//  RealmLocationModel.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLocationModel: Object {
    
    @objc dynamic var locationId: String = ""
    @objc dynamic var shortName: String = ""
    @objc dynamic var detailedName: String? = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    
    override static func primaryKey() -> String? {
        "locationId"
    }
    
    // MARK: Модель для сверки с геопозицией
    
    static let geolocation: RealmLocationModel = {
        var model = RealmLocationModel()
        
        model.locationId = "-1"
        model.shortName = ""
        model.detailedName = ""
        model.latitude = 0
        model.longitude = 0
        
        return model
    }()

}
