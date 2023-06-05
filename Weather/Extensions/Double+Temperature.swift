//
//  Double+Temperature.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

extension Double {
    
    var asTemperatureString: String {
        "\(rounded().int)°"
    }
    
}
