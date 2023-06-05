//
//  BaseRequestRetrier.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Alamofire
import Foundation

class BaseRequestRetrier: RequestInterceptor {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        urlRequest
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard request.retryCount < 4 else {
            print("REQUEST RETRIER: Task failed to finish in 4 attempts. RIP")
            return completion(.doNotRetry)
        }
        
        guard let response = request.task?.response as? HTTPURLResponse else {
            print("REQUEST RETRIER: Task returned no response. Trying again. Attempt #\(request.retryCount + 1)")
            return completion(.retryWithDelay(Double(request.retryCount) * 3.0))
        }
        
        switch response.statusCode {
        default: completion(.doNotRetry)
        }
    }
    
}
