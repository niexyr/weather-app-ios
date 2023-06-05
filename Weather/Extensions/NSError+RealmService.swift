//
//  NSError+RealmService.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

extension NSError {
    
    enum RealmServiceError {
        
        private static let domain = "RealmServiceError"
        
        /// CurrentlyInWriteTransaction
        static let currentlyInWriteTransaction = NSError(
            domain: domain,
            code: 2000,
            userInfo: [NSLocalizedDescriptionKey: "Realm уже находится в процессе транзакции записи данных"]
        )
        
    }
    
}
