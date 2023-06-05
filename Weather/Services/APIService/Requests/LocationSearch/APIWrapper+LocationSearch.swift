//
//  APIWrapper+LocationSearch.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

extension APIWrapper {
    
    func performLocationSearch(text: String) -> Single<LocationSearchResponseData?> {
        guard isReachable else {
            return .error(NSError.APIWrapperError.noConnectionError)
        }
        
        let request = LocationSearchRequest(text: text)
        
        return provider.rx
            .request(.locationSearch(request: request))
            .convertNoConnectionError()
            .mapAsDefaultResponse()
    }
    
}
