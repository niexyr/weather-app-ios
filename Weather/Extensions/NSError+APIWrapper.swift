//
//  NSError+APIWrapper.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation

extension NSError {
    
    enum APIWrapperError {
        
        static let domain = "APIWrapperError"
        static let responseStatusCodeKey = "responseStatusCodeKey"
        
        /// Запрос зафейлился. Известен только код ошибки
        static func codeIsNotSuccessful(_ code: Int) -> NSError {
            NSError(
                domain: domain,
                code: 1000,
                userInfo: [
                    responseStatusCodeKey: code,
                    NSLocalizedDescriptionKey: "В ходе выполнения запроса произошла ошибка \(code)"
                ]
            )
        }
        
        /// Ошибка отсутствия соединения
        static let noConnectionError = NSError(
            domain: domain,
            code: 1001,
            userInfo: [NSLocalizedDescriptionKey: "Нет соединения"]
        )
        
        /// Ошибка маппинга запроса с успешным кодом
        static let successfulResponseMappingError = NSError(
            domain: domain,
            code: 1002,
            userInfo: [NSLocalizedDescriptionKey: "Ошибка маппинга респонза в запросе с успешным кодом"]
        )
        
    }
    
}
