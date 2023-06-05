//
//  Observable+Extensions.swift
//  Weather
//
//  Created by Valery Shamshin on 02.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol OptionalType {
    
    associatedtype Wrapped
    
    var optional: Wrapped? { get }
    
}

extension Optional: OptionalType {
    
    public var optional: Wrapped? { self }
    
}

extension ObservableType where Element == Bool {
    
    func not() -> Observable<Bool> {
        self.map(!)
    }
    
}

extension SharedSequenceConvertibleType {
    
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        map { _ in }
    }
    
    func mapToOptional() -> SharedSequence<SharingStrategy, Element?> {
        map { value -> Element? in value }
    }
    
}

extension SharedSequenceConvertibleType where Element == Bool {
    
    func not() -> SharedSequence<SharingStrategy, Bool> {
        self.map(!)
    }
    
    func isTrue() -> SharedSequence<SharingStrategy, Bool> {
        flatMap { isTrue in
            guard isTrue else {
                return SharedSequence<SharingStrategy, Bool>.empty()
            }
            return SharedSequence<SharingStrategy, Bool>.just(true)
        }
    }
    
    func filterFalse() -> SharedSequence<SharingStrategy, Bool> {
        filter { !$0 }
    }
    
}

extension SharedSequenceConvertibleType where Element: OptionalType {
    
    func ignoreNil() -> SharedSequence<SharingStrategy, Element.Wrapped> {
        flatMap { value in
            value.optional.map { .just($0) } ?? .empty()
        }
    }
    
}

extension ObservableType {
    
    func catchErrorJustComplete() -> Observable<Element> {
        catchErr { _ in .empty() }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in .empty() }
    }
    
    func mapToVoid() -> Observable<Void> {
        map { _ in }
    }
    
    func mapToOptional() -> Observable<Element?> {
        map { value -> Element? in value }
    }
    
}

extension ObservableType where Element: OptionalType {
    
    func ignoreNil() -> Observable<Element.Wrapped> {
        flatMap { value in
            value.optional.map { Observable.just($0) } ?? Observable.empty()
        }
    }
    
}

extension ObservableType where Element: Collection {
    
    func ignoreEmpty() -> Observable<Element> {
        flatMap { array in
            array.isEmpty ? Observable.empty() : Observable.just(array)
        }
    }
    
}

extension PrimitiveSequence where Trait == SingleTrait {
    
    func mapToOptional() -> Single<Element?> {
        map { value -> Element? in value }
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        asDriver { _ in .empty() }
    }
    
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    
    func doOnError(_ onError: ((Error) -> Void)?) -> Single<Element> {
        self.do(onError: onError)
    }
    
}

extension PrimitiveSequence {
    func catchErr(_ handler: @escaping (Swift.Error) throws -> PrimitiveSequence<Trait, Element>)
        -> PrimitiveSequence<Trait, Element> {
        `catch`(handler)
    }
}

extension ObservableType {
    func catchErr(_ handler: @escaping (Swift.Error) throws -> Observable<Element>)
        -> Observable<Element> {
        `catch`(handler)
    }
}
