//
//  APITarget.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Moya
import Foundation

enum APITarget {
    
    case getCurrentWeather(request: GetCurrentWeatherRequest)
    case getDetailedWeather(request: GetDetailedWeatherRequest)
    case locationSearch(request: LocationSearchRequest)
    
}

extension APITarget: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getCurrentWeather, .getDetailedWeather: return URL(string: "https://api.openweathermap.org")!
        case .locationSearch: return URL(string: "https://api.teleport.org/api")!
        }
    }
    
    var path: String {
        switch self {
        case .getCurrentWeather: return "data/2.5/group"
        case .getDetailedWeather: return "data/2.5/onecall"
        case .locationSearch: return "cities"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCurrentWeather, .getDetailedWeather, .locationSearch: return .get
        }
    }
    
    var headers: [String: String]? {
        let defaultHeaders: [String: String] = {
            switch self {
            default: return ["Content-Type": "application/json"]
            }
        }()
        
        return defaultHeaders
    }
    
    var task: Task {
        switch self {
        case .getCurrentWeather, .getDetailedWeather, .locationSearch:
            return .requestParameters(parameters: requestParameters, encoding: URLEncoding.default)
        }
    }
    
    var requestParameters: [String: Any] {
        switch self {
        case let .getCurrentWeather(request): return request.requestParameters
        case let .getDetailedWeather(request): return request.requestParameters
        case let .locationSearch(request): return request.requestParameters
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
}
