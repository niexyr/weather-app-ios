//
//  LocationModel.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

struct LocationModel: Equatable {
    
    let locationId: String
    let shortName: String
    let detailedName: String?
    let latitude: Double
    let longitude: Double
    
    var locationFullName: String {
        if let detailedName = detailedName, !detailedName.isEmpty {
            return "\(shortName) (\(detailedName))"
        } else {
            return "\(shortName)"
        }
    }
    
    init(
        locationId: String,
        shortName: String,
        detailedName: String?,
        latitude: Double,
        longitude: Double
    ) {
        self.locationId = locationId
        self.shortName = shortName
        self.detailedName = detailedName
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(realmModel: RealmLocationModel) {
        locationId = realmModel.locationId
        shortName = realmModel.shortName
        detailedName = realmModel.detailedName
        latitude = realmModel.latitude
        longitude = realmModel.longitude
    }
    
    func asRealmModel() -> RealmLocationModel {
        let model = RealmLocationModel()
        
        model.locationId = locationId
        model.shortName = shortName
        model.detailedName = detailedName
        model.latitude = latitude
        model.longitude = longitude
        
        return model
    }
    
}
