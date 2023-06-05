//
//  AddNewLocationViewModel.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import RxSwift
import RxCocoa
import XCoordinator
import UIKit

struct AddNewLocationSearchState: OptionSet {
    
    let rawValue: Int
    
    static let hasValidSearchText = AddNewLocationSearchState(rawValue: 1 << 0)
    static let isCurrentlySearching = AddNewLocationSearchState(rawValue: 1 << 1)
    static let hasSomeValidResults = AddNewLocationSearchState(rawValue: 1 << 2)
    static let isUserCurrentlyTyping = AddNewLocationSearchState(rawValue: 1 << 3)
    static let failedLastSearchWithError = AddNewLocationSearchState(rawValue: 1 << 4)
    
}

protocol AddNewLocationViewModelDelegate: AnyObject {
    
    func addNewLocationViewModel(
        _ viewModel: AddNewLocationViewModel,
        didSuccessfullyAddNewLocation: LocationModel,
        withCurrentWeather: APIWeatherSummary
    )
    
}

class AddNewLocationViewModel: BaseViewModel {
    
    private let apiWrapper: APIWrapper
    private let realmService: RealmService
    private let router: WeakRouter<AppRoute>
    
    private let loadedData = BehaviorSubject<LocationSearchResponseData?>(value: nil)
    
    private weak var delegate: AddNewLocationViewModelDelegate?
    
    init(
        apiWrapper: APIWrapper,
        realmService: RealmService,
        delegate: AddNewLocationViewModelDelegate,
        router: WeakRouter<AppRoute>
    ) {
        self.apiWrapper = apiWrapper
        self.realmService = realmService
        self.delegate = delegate
        self.router = router
    }
    
    func transform(input: Input) -> Output {
        let searchActivityTracker = ActivityTracker()
        let searchErrorTracker = ErrorTracker()
        
        let weatherAvailabilityActivityTracker = ActivityTracker()
        let weatherAvailabilityErrorTracker = ErrorTracker()
        
        let realmActivityTracker = ActivityTracker()
        let realmErrorTracker = ErrorTracker()
        
        // MARK: Обработка ошибок Realm
        
        realmErrorTracker.asDriver()
            .drive(
                onNext: { [weak self] error in
                    let dismissAction = UIAlertAction(title: "ОК", style: .default) { _ in
                        self?.router.trigger(.dismiss)
                    }
                    
                    self?.router.trigger(
                        .dialog(
                            title: "Критическая ошибка БД",
                            message: error.localizedDescription,
                            actions: [dismissAction],
                            style: .alert
                        )
                    )
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: Обработка ошибок загрузки погоды
        
        weatherAvailabilityErrorTracker
            .drive(
                onNext: { [weak self] error in
                    let message: String = {
                        let nsError = error as NSError
                        
                        guard nsError.domain == NSError.APIWrapperError.domain,
                            nsError.code == 1000,
                            let statusCode = nsError.userInfo[NSError.APIWrapperError.responseStatusCodeKey] as? Int,
                            statusCode == 404 else {
                            return error.localizedDescription
                        }
                        
                        return "Эта локация недоступна в сервисе OpenWeatherMap"
                    }()
                    
                    self?.router.trigger(
                        .alert(title: "Ошибка", message: message)
                    )
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: Введенный текст без лишних пробелов и переносов
        
        let mappedSearchText = input.searchText
            .map { $0?.trimmed ?? "" }
        
        // MARK: Обработка ошибок поиска
        // При получении ошибки - отображаем это в стейте
        // При вводе нового символа пользователем - сбрасываем актуальность ошибки
        
        let actualSearchError: Driver<Error?> = .merge(
            searchErrorTracker.asDriver().mapToOptional(),
            mappedSearchText.map { _ in nil }
        )
        
        // MARK: Автоматически очищаем модели, когда введенный текст становится пустым
        
        let clearedModels = mappedSearchText
            .filter { $0.isEmpty }
            .map { _ -> [AddNewLocationSectionModel] in [] }
        
        // MARK: Поиск городов
        
        let loadedData = self.loadedData.asDriver(onErrorJustReturn: nil)
        
        mappedSearchText
            .debounce(.milliseconds(333))
            .filter { !$0.isEmpty }
            .flatMap { [weak self] text -> Driver<LocationSearchResponseData?> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.apiWrapper
                    .performLocationSearch(text: text)
                    .trackActivity(searchActivityTracker)
                    .trackError(searchErrorTracker)
                    .asDriver(onErrorJustReturn: nil)
            }
            .drive(
                onNext: { [weak self] response in
                    self?.loadedData.onNext(response)
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: Создание моделей для списка из загруженных данных
            
        let loadedModels = loadedData
            .map { responseData -> [AddNewLocationSectionModel] in
                guard let responseData = responseData else {
                    return []
                }
                
                let results = responseData.embeddedSearchResults.searchResults
                
                let items = results.compactMap { result -> AddNewLocationDataItem? in
                    guard let shortName = result.matchingAlternateNames.first?.name,
                        let detailedName = result.detailedName else {
                        return nil
                    }
                    
                    let model = LocationModel(
                        locationId: result.id,
                        shortName: shortName,
                        detailedName: detailedName,
                        latitude: result.embeddedCity.city.location.coordinates.latitude,
                        longitude: result.embeddedCity.city.location.coordinates.longitude
                    )
                    
                    return AddNewLocationDataItem.location(model: model)
                }
                
                let sectionModel = AddNewLocationSectionModel(identity: "Main", items: items)
                
                return [sectionModel]
            }
        
        let sectionModels: Driver<[AddNewLocationSectionModel]> = .merge(clearedModels, loadedModels)
        
        // MARK: Отслеживание состояния, печатает ли сейчас пользователь
        
        let isUserCurrentlyTyping: Driver<Bool> = .merge(
            mappedSearchText.map { _ in true },
            mappedSearchText.debounce(.milliseconds(333)).map { _ in false }
        )
        
        // MARK: Общий стейт поиска
        
        let searchState = Driver
            .combineLatest(
                mappedSearchText,
                searchActivityTracker.asDriver(),
                loadedModels,
                isUserCurrentlyTyping,
                actualSearchError
            )
            .map { args -> AddNewLocationSearchState in
                let (searchText, isLoading, currentModels, isCurrentlyTyping, searchError) = args
                
                var state = AddNewLocationSearchState()
                
                if !searchText.isEmpty {
                    state.insert(.hasValidSearchText)
                }
                
                if isLoading {
                    state.insert(.isCurrentlySearching)
                }
                
                if !(currentModels.first?.items ?? []).isEmpty {
                    state.insert(.hasSomeValidResults)
                }
                
                if isCurrentlyTyping {
                    state.insert(.isUserCurrentlyTyping)
                }
                
                if searchError != nil {
                    state.insert(.failedLastSearchWithError)
                }
                
                return state
            }
        
        // MARK: При нажатии на ячейку:
        // 1. Достаем связанную с ячейкой модель локации
        
        let selectedLocationModel = input.itemSelected
            .withLatestFrom(sectionModels) { ($0, $1) }
            .map { indexPath, sectionModels -> LocationModel? in
                guard let item = sectionModels[safe: indexPath.section]?.items[safe: indexPath.row],
                    case let .location(model) = item else {
                    return nil
                }
                
                return model
            }
            .ignoreNil()
        
        // MARK: 2. Проверяем, не добавлен ли уже этот город в БД
        
        let withModelFromDb = selectedLocationModel
            .flatMap { [weak self] selectedModel -> Driver<(LocationModel, RealmLocationModel?)> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.realmService
                    .getLocation(by: selectedModel.locationId)
                    .trackError(realmErrorTracker)
                    .trackActivity(realmActivityTracker)
                    .map { storedModel in (selectedModel, storedModel) }
                    .asDriverOnErrorJustComplete()
            }
        
        // MARK: 3. Если уже добавлен - просто переходим на главный экран (аналогично нативному приложению)
        
        withModelFromDb
            .filter { _, storedModel in storedModel != nil }
            .drive(
                onNext: { [weak self] _, _ in
                    self?.router.trigger(.dismiss)
                }
            )
            .disposed(by: disposeBag)
        
        // MARK: 4. Если не добавлен, то:
        // а) Проверяем, доступна ли эта локация в сервисе для получения погоды
        // б) Если доступна - сохраняем это добро в БД, а затем возвращаемся на главный экран
        
        withModelFromDb
            .filter { _, storedModel in storedModel == nil }
            .map { selectedModel, _ in selectedModel }
            .flatMap { [weak self] selectedModel -> Driver<(LocationModel, APIWeatherSummary)?> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.apiWrapper
                    .getCurrentWeather(locationIds: [selectedModel.locationId])
                    .trackError(weatherAvailabilityErrorTracker)
                    .trackActivity(weatherAvailabilityActivityTracker)
                    .map { response in
                        guard let weather = response?.list.first else {
                            return nil
                        }
                        
                        return (selectedModel, weather)
                    }
                    .asDriver(onErrorJustReturn: nil)
            }
            .ignoreNil()
            .flatMap { [weak self] selectedModel, weather -> Driver<(LocationModel, APIWeatherSummary)?> in
                guard let self = self else {
                    return .empty()
                }
                
                return self.realmService
                    .storeLocation(selectedModel.asRealmModel())
                    .map { (selectedModel, weather) }
                    .trackError(realmErrorTracker)
                    .asDriver(onErrorJustReturn: nil)
            }
            .ignoreNil()
            .drive(
                onNext: { [weak self] addedModel, weather in
                    guard let self = self else {
                        return
                    }
                    
                    self.delegate?.addNewLocationViewModel(
                        self,
                        didSuccessfullyAddNewLocation: addedModel,
                        withCurrentWeather: weather
                    )
                    
                    self.router.trigger(.dismiss)
                }
            )
            .disposed(by: disposeBag)
        
        let isBlocking = Driver
            .combineLatest(weatherAvailabilityActivityTracker.asDriver(), realmActivityTracker.asDriver())
            .map { $0 || $1 }
        
        return Output(sectionModels: sectionModels, searchState: searchState, isBlocking: isBlocking)
    }
    
}

extension AddNewLocationViewModel {
    
    struct Input {
        let searchText: Driver<String?>
        let itemSelected: Driver<IndexPath>
    }
    
    struct Output {
        let sectionModels: Driver<[AddNewLocationSectionModel]>
        let searchState: Driver<AddNewLocationSearchState>
        let isBlocking: Driver<Bool>
    }
    
}
