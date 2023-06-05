//
//  Double+WindDirections.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

extension Double {
    
    var asWindDirection: String {
        let directions = [
            "С", "ССВ", "СВ", "ВСВ", "В", "ВЮВ", "ЮВ", "ЮЮВ", "Ю", "ЮЮЗ", "ЮЗ", "ЗЮЗ", "З", "ЗСЗ", "СЗ", "ССЗ"
        ]
        
        let position = Int((self + 11.25) / 22.5)
        return directions[position % 16]
    }
    
}
