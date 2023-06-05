//
//  RealmService.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

class RealmService {
    
    // swiftlint:disable:next force_try
    private let realm = try! Realm()
    
    func getStoredLocations() -> Single<[RealmLocationModel]> {
        Single.create { [unowned self] single in
            single(.success(self.storedLocations))
            return Disposables.create()
        }
    }
    
    func getLocation(by id: String) -> Single<RealmLocationModel?> {
        let object = realm.object(ofType: RealmLocationModel.self, forPrimaryKey: id)
        
        return Observable.just(object)
            .asSingle()
    }
    
    func storeLocation(_ model: RealmLocationModel) -> Single<Void> {
        realm.rx.save(object: model)
    }
    
    func deleteLocation(with id: String) -> Single<Void> {
        let predicate = NSPredicate(format: "locationId == %@", id)
        
        return realm.rx.delete(predicate: predicate, ofType: RealmLocationModel.self)
    }
    
    func deleteDatabase() -> Single<Void> {
        realm.rx.deleteDatabase()
    }
    
    private var storedLocations: [RealmLocationModel] {
        let objects = Array(realm.objects(RealmLocationModel.self))
        
        guard objects.isEmpty else {
            return objects
        }
        
        do {
            realm.beginWrite()
            try realm.commitWrite()
        } catch {
            print(error)
        }
        
        return []
    }
    
}
