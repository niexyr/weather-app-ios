//
//  RxRealm+Extensions.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

extension Reactive where Base == Realm {
    
    func save<R: Object>(object: R, update: Bool = true) -> Single<Void> {
        Single.create { single in
            do {
                print("RealmService: Writing...", R.self)
                
                if self.base.isInWriteTransaction {
                    throw(NSError.RealmServiceError.currentlyInWriteTransaction)
                }
                
                try self.base.write {
                    self.base.add(object, update: Realm.UpdatePolicy.all)
                }
                
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
        .retry(when: retry)
    }
    
    func delete<R: Object>(predicate: NSPredicate, ofType type: R.Type) -> Single<Void> {
        Single.create { single in
            do {
                let objects = self.base.objects(R.self).filter(predicate)
                
                if self.base.isInWriteTransaction {
                    throw(NSError.RealmServiceError.currentlyInWriteTransaction)
                }
                
                try self.base.write {
                    self.base.delete(objects)
                }
                
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
        .retry(when: retry)
    }

    func delete<R: Object>(allOf type: R.Type) -> Single<Void> {
        Single.create { single in
            do {
                print("RealmService: Deleting...", R.self)
                
                let objects = self.base.objects(R.self)
                
                if self.base.isInWriteTransaction {
                    throw(NSError.RealmServiceError.currentlyInWriteTransaction)
                }
                
                try self.base.write {
                    self.base.delete(objects)
                }
                
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
        .retry(when: retry)
    }
    
    func deleteDatabase() -> Single<Void> {
        Single.create { single in
            do {
                print("RealmService: Deleting database contents...")
                
                if self.base.isInWriteTransaction {
                    throw(NSError.RealmServiceError.currentlyInWriteTransaction)
                }
                
                try self.base.write {
                    self.base.deleteAll()
                }
                
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            
            return Disposables.create()
        }
        .retry(when: retry)
    }
    
    private func retry(_ errorObservable: Observable<Error>) -> Observable<Void> {
        errorObservable.flatMap { error -> Observable<Void> in
            guard error == NSError.RealmServiceError.currentlyInWriteTransaction else {
                return .error(error)
            }
            
            return Observable.just(()).delay(.milliseconds(1000), scheduler: MainScheduler.instance)
        }
    }
    
}
