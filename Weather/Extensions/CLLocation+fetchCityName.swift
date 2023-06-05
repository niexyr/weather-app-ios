//
//  CLLocation+fetchCityName.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import MapKit

extension CLLocation {
    func fetchCityName(
        completion: @escaping (
            _ city: String?,
            _ error: Error?
        ) -> ()
    ) {
        CLGeocoder().reverseGeocodeLocation(self) {
            completion($0?.first?.locality, $1)
        }
    }
}
