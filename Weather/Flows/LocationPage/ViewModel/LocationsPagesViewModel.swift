//
//  LocationsPagesViewModel.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import RxSwift
import RxCocoa
import XCoordinator
import UIKit

class LocationsPagesViewModel: BaseViewModel {
    
    private let apiWrapper: APIWrapper
    private let realmService: RealmService
    private let locationService: LocationService
    private let router: WeakRouter<AppRoute>
    
    private let loadedCurrentLocationName = PublishSubject<UserCoordinatesModel?>()
    private let loadedCurrentLocationWeatherData = PublishSubject<GetDetailedWeatherResponseData?>()
    
    private let loadedLocations = BehaviorSubject<[LocationModel]>(value: [])
    private let loadedWeather = BehaviorSubject<[APIWeatherSummary]>(value: [])
    
    private let newItemAddedSubject = PublishSubject<Void>()
    private let requestLocationTrigger = BehaviorSubject<Void>(value: ())
    
    init(apiWrapper: APIWrapper,
         realmService: RealmService,
         router: WeakRouter<AppRoute>,
         locationService: LocationService
    ) {
        self.apiWrapper = apiWrapper
        self.realmService = realmService
        self.locationService = locationService
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let activityTracker = ActivityTracker()
        let errorTracker = ErrorTracker()
        
        locationService.delegate = self
        
        // MARK: Обработка ошибок
        
        let retryAfterErrorTrigger = PublishSubject<Void>()
        
        errorTracker.asDriver()
            .withLatestFrom(loadedLocations.asDriver(onErrorJustReturn: [])) { ($0, $1) }
            .drive(
                onNext: { [weak self] error, storedLocations in
                    let error = error as NSError
                    
                    guard error.code != 1001, !storedLocations.isEmpty else {
                        return
                    }
                    
                    let retryAction = UIAlertAction(title: "Попробовать снова", style: .default) { _ in
                        retryAfterErrorTrigger.onNext(())
                    }
                    
                    self?.router.trigger(
                        .dialog(
                            title: "Ошибка",
                            message: error.localizedDescription,
                            actions: [retryAction],
                            style: .alert
                        )
                    )
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: Автореконнект
        
        apiWrapper.isReachableObservable
            .subscribe(
                onNext: { [weak self] isReachable in
                    retryAfterErrorTrigger.onNext(())
                    self?.requestLocationTrigger.onNext(())
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: Получение текущей геопозиции
        
        let currentLocationDataContainer = Driver
            .combineLatest(
                loadedCurrentLocationName.asDriver(onErrorJustReturn: nil),
                loadedCurrentLocationWeatherData.asDriver(onErrorJustReturn: nil)
            )
        
        currentLocationDataContainer
            .drive()
            .disposed(by: disposeBag)
        
        let requestLocationTrigger = requestLocationTrigger.asDriver(onErrorJustReturn: ())
        
        Driver
            .combineLatest(
                requestLocationTrigger,
                locationService.currentUserLocation.asDriver(onErrorJustReturn: nil)
            )
            .flatMapLatest {
                [weak self] _, userLocation -> Driver<GetDetailedWeatherResponseData?> in
                guard let self = self,
                      let userLocation = userLocation else {
                    self?.loadedCurrentLocationName.onNext(
                        UserCoordinatesModel(
                            cityName: "Текущее местоположение 📍",
                            location: nil
                        )
                    )
                    
                    return .just(nil)
                }
                
                userLocation.fetchCityName { cityName, error in
                    self.loadedCurrentLocationName.onNext(
                        UserCoordinatesModel(
                            cityName: "\(cityName ?? "Текущее местоположение") 📍",
                            location: userLocation
                        )
                    )
                }
                
                return self.apiWrapper
                    .getDetailedWeather(
                        latitude: userLocation.coordinate.latitude,
                        longitude: userLocation.coordinate.longitude
                    )
                    .doOnError { [weak self] _ in
                        self?.loadedCurrentLocationWeatherData.onNext(nil)
                    }
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: nil)
            }
            .drive(
                onNext: { [weak self] response in
                    self?.loadedCurrentLocationWeatherData.onNext(response)
                })
            .disposed(by: disposeBag)
        
        requestLocationTrigger
            .drive(onNext: { [weak self] in
                self?.locationService.requestLocation()
            })
            .disposed(by: disposeBag)
        
        // MARK: Модели для отображения ячеек с погодой в списке
        
        let loadedLocations = loadedLocations.asDriver(onErrorJustReturn: [])
        let loadedWeather = loadedWeather.asDriver(onErrorJustReturn: [])
        
        let sectionModels = Driver
            .combineLatest(
                loadedLocations,
                loadedWeather,
                currentLocationDataContainer
            )
            .map { container -> [LocationsPagesSectionModel] in
                let (locations, weather, (currentLocation, currentLocationWeatherData)) = container
                var items = locations.compactMap { locationModel -> LocationsPagesDataItem? in
                    guard let relatedWeather = (weather.first {
                        $0.id.string == locationModel.locationId
                    }) else {
                        return LocationsPagesDataItem.preview(
                            location: locationModel,
                            temperature: nil,
                            iconUrl: nil,
                            weatherDescription: "Нет данных"
                        )
                    }
                    
                    return LocationsPagesDataItem.preview(
                        location: locationModel,
                        temperature: relatedWeather.main.temp,
                        iconUrl: relatedWeather.weather.first?.iconUrl,
                        weatherDescription: relatedWeather.weather.first?.description
                    )
                }
                
                let currentLocationPageItem = LocationsPagesDataItem.preview(
                    location: LocationModel(
                        locationId: RealmLocationModel.geolocation.locationId,
                        shortName: currentLocation?.cityName ?? "Нет данных",
                        detailedName: "",
                        latitude: currentLocation?.location?.coordinate.latitude ?? 0,
                        longitude: currentLocation?.location?.coordinate.longitude ?? 0
                    ),
                    temperature: currentLocationWeatherData?.current.temp,
                    iconUrl: currentLocationWeatherData?.current.weather.first?.iconUrl,
                    weatherDescription: currentLocationWeatherData?.current.weather.first?.description ?? "Нет данных"
                )
                
                items.insert(
                    currentLocationPageItem,
                    at: 0
                )
                
                let sectionModel = LocationsPagesSectionModel(identity: "Main", items: items)
                
                return [sectionModel]
            }
        
        // MARK: Триггер для полной перезагрузки данных
        
        let refreshDataTrigger = Driver.merge(
            retryAfterErrorTrigger.asDriverOnErrorJustComplete(),
            .just(())
        )
        
        refreshDataTrigger
            .flatMap { [weak self] _ -> Driver<[RealmLocationModel]> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.realmService
                    .getStoredLocations()
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .map { realmModels in
                realmModels.map { LocationModel(realmModel: $0) }
            }
            .do(
                onNext: { [weak self] locationModels in
                    self?.loadedLocations.onNext(locationModels)
                }
            )
                .map { locationModels -> [[String]] in
                    locationModels.map { $0.locationId }.group(by: 15) ?? []
                }
                .delay(.milliseconds(50))
                .flatMap { [weak self] groupedIds -> Driver<[APIWeatherSummary]> in
                    guard let self = self else {
                        return .empty()
                    }
                    
                    let queries = groupedIds.map { self.apiWrapper.getCurrentWeather(locationIds: $0) }
                    
                    return Single
                        .zip(queries)
                        .doOnError { [weak self] _ in
                            self?.loadedWeather.onNext([])
                        }
                        .trackActivity(activityTracker)
                        .trackError(errorTracker)
                        .map { responses in
                            responses.compactMap { $0 }.map { $0.list }.flatMap { $0 }
                        }
                        .asDriverOnErrorJustComplete()
                }
                .drive(
                    onNext: { [weak self] loadedWeather in
                        self?.loadedWeather.onNext(loadedWeather)
                    }
                )
                .disposed(by: disposeBag)
        
        // MARK: Удаление локации
        
        input.deleteLocationTrigger
            .flatMap { [weak self] id -> Driver<Void?> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.realmService
                    .deleteLocation(with: id)
                    .mapToOptional()
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriver(onErrorJustReturn: nil)
            }
            .ignoreNil()
            .flatMap { [weak self] _ -> Driver<[RealmLocationModel]> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.realmService
                    .getStoredLocations()
                    .trackActivity(activityTracker)
                    .trackError(errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .map { realmModels in
                realmModels.map { LocationModel(realmModel: $0) }
            }
            .drive(
                onNext: { [weak self] actualModels in
                    self?.loadedLocations.onNext(actualModels)
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: Триггер нажатия на кнопку "Добавить локацию"
        
        input.addLocationTrigger
            .drive(
                onNext: { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    self.router.trigger(.addNewLocation(delegate: self))
                }
            )
            .disposed(by: disposeBag)
        
        return Output(
            sectionModels: sectionModels,
            isLoading: activityTracker.asDriver(),
            newItemAdded: newItemAddedSubject.asDriverOnErrorJustComplete()
        )
    }
    
}

extension LocationsPagesViewModel {
    
    struct Input {
        let addLocationTrigger: Driver<Void>
        let deleteLocationTrigger: Driver<String>
        let itemSelected: Driver<IndexPath>
    }
    
    struct Output {
        let sectionModels: Driver<[LocationsPagesSectionModel]>
        let isLoading: Driver<Bool>
        let newItemAdded: Driver<Void>
    }
    
}

extension LocationsPagesViewModel: AddNewLocationViewModelDelegate {
    
    func addNewLocationViewModel(
        _ viewModel: AddNewLocationViewModel,
        didSuccessfullyAddNewLocation location: LocationModel,
        withCurrentWeather weather: APIWeatherSummary
    ) {
        realmService
            .getStoredLocations()
            .asDriverOnErrorJustComplete()
            .map { realmModels in
                realmModels.map { LocationModel(realmModel: $0) }
            }
            .do(
                onNext: { [weak self] actualLocationModels in
                    self?.loadedLocations.onNext(actualLocationModels)
                }
            )
            .withLatestFrom(loadedWeather.asDriver(onErrorJustReturn: []))
            .map { currentWeatherData in
                var mutableData = currentWeatherData
                
                mutableData.removeAll { $0.id == weather.id }
                mutableData.append(weather)
                
                return mutableData
            }
            .drive(
                onNext: { [weak self] actualWeatherData in
                    self?.loadedWeather.onNext(actualWeatherData)
                    self?.newItemAddedSubject.onNext(())
                }
            )
            .disposed(by: disposeBag)
    }
    
}

extension LocationsPagesViewModel: LocationServiceDelegate {
    
    func handleNoAccess() {
        let acceptAction = UIAlertAction(title: "В настройки", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        let actions: [UIAlertAction] = [
            acceptAction,
            cancelAction
        ]
        
        router.trigger(
            .dialog(
                title: "Ошибка доступа",
                message: "Чтобы получить доступ о погоде в текущем месте, необходимо разрешить доступ в настройках. Перейти в настройки?",
                actions: actions,
                style: .alert
            )
        )
    }
    
}
