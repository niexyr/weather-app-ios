//
//  APIWrapper.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Moya
import Alamofire
import RxSwift
import RxCocoa
import Foundation

class APIWrapper {
    
    let disposeBag = DisposeBag()
    
    let reachability: NetworkReachabilityManager
    
    let isReachableObservable: BehaviorSubject<Bool>
    
    let provider: MoyaProvider<APITarget> = {
        let session = Session(interceptor: BaseRequestRetrier())
        return MoyaProvider<APITarget>(session: session)
    }()
    
    var isReachable: Bool {
        reachability.isReachable
    }
    
    init() {
        reachability = NetworkReachabilityManager()!
        
        isReachableObservable = BehaviorSubject<Bool>(value: reachability.isReachable)
        
        reachability.startListening { [weak self] status in
            if case .reachable = status {
                self?.isReachableObservable.onNext(true)
            } else {
                self?.isReachableObservable.onNext(false)
            }
        }
    }
    
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    
    func mapAsDefaultResponse<T: Decodable>() -> Single<T> {
        flatMap { response in
            if 200...299 ~= response.statusCode {
                do {
                    let mappedResponse = try response.map(T.self)
                    return .just(mappedResponse)
                } catch {
                    throw NSError.APIWrapperError.successfulResponseMappingError
                }
            }
            
            throw NSError.APIWrapperError.codeIsNotSuccessful(response.statusCode)
        }
    }
    
    func convertNoConnectionError() -> PrimitiveSequence<Trait, Element> {
        catchErr { error in
            let nsError = error as NSError
            
            guard nsError.domain == "Moya.MoyaError",
                nsError.code == 6,
                let afError = nsError.userInfo["NSUnderlyingError"] as? AFError,
                let underlyingError = afError.underlyingError as NSError?,
                underlyingError.domain == "NSURLErrorDomain",
                underlyingError.code == -1009 else {
                throw error
            }

            throw NSError.APIWrapperError.noConnectionError
        }
    }
    
}
