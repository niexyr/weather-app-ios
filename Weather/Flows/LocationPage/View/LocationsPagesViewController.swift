//
//  LocationsPagesViewController.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import JGProgressHUD

class LocationsPagesViewController: BaseViewController, LoaderPresentable {
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var dataSource: RxCollectionViewSectionedAnimatedDataSource<LocationsPagesSectionModel>?
    
    var loader: JGProgressHUD?
    
    var loaderContainer: UIView {
        navigationController?.view ?? view
    }
    
    private let deleteButton = UIBarButtonItem(
        barButtonSystemItem: .trash,
        target: nil,
        action: nil
    )

    private let addButton = UIBarButtonItem(
        barButtonSystemItem: .add,
        target: nil,
        action: nil
    )
    
    private let viewModel: LocationsPagesViewModel
    private let deleteLocationTrigger = PublishSubject<String>()
    private let didStopCollectionViewTrigger = PublishSubject<IndexPath>()
    
    init(viewModel: LocationsPagesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bind()
    }
    
    private func configureView() {
        title = "Ваши локации"
        
        configureNavBarItems(isDeleteButtonHidden: true)
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView.setCollectionViewLayout(layout, animated: true)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        collectionView.register(nibWithCellClass: LocationsPageCell.self)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<LocationsPagesSectionModel>(
            configureCell: { _, collectionView, indexPath, item in
                switch item {
                case let .preview(location, temperature,  iconUrl, weatherDescription):
                    let cell = collectionView.dequeueReusableCell(withClass: LocationsPageCell.self, for: indexPath)
                    
                    cell.configure(
                        location: location,
                        temperature: temperature,
                        iconUrl: iconUrl,
                        weatherDescription: weatherDescription
                    )
                    
                    return cell
                }
            }
        )
        
        dataSource.animationConfiguration = .init(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade
        )
        
        collectionView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.dataSource = dataSource
    }
    
    private func bind() {
        deleteButton.rx.tap
            .withLatestFrom(didStopCollectionViewTrigger)
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let item = self.dataSource?[indexPath],
                      case let .preview(location, _, _, _) = item else {
                    return
                }
                
                self.deleteLocationTrigger.onNext(location.locationId)
                self.reconfigureNavigationBarItems(with: self.collectionView)
            })
            .disposed(by: disposeBag)
        
        let input = LocationsPagesViewModel.Input(
            addLocationTrigger: addButton.rx.tap.asDriver(),
            deleteLocationTrigger: deleteLocationTrigger.asDriverOnErrorJustComplete(),
            itemSelected: collectionView.rx.itemSelected.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sectionModels
            .drive(collectionView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        output.newItemAdded
            .drive(onNext: { [weak self] in
                guard let modelsCount = self?.dataSource?.sectionModels.first?.items.count else {
                    return
                }
                
                let indexPath = IndexPath(row: modelsCount - 1, section: 0)
                self?.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .debounce(.milliseconds(25))
            .drive(
                onNext: { [weak self] isLoading in
                    self?.updateLoader(isEnabled: isLoading, detailText: nil)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func reconfigureNavigationBarItems(with: UIScrollView) {
        var visibleRect = CGRect()

        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size

        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
            didStopCollectionViewTrigger.onNext(indexPath)
            controlNavigationBarItems(with: indexPath)
        }
    }

    private func controlNavigationBarItems(with indexPath: IndexPath) {
        let ignoredIds = [RealmLocationModel.geolocation.locationId]
        
        guard let dataSource = dataSource,
              !ignoredIds.contains(dataSource[indexPath].identity) else {
            configureNavBarItems(isDeleteButtonHidden: true)
            return
        }

        configureNavBarItems(isDeleteButtonHidden: false)
    }
    
    private func configureNavBarItems(isDeleteButtonHidden: Bool = false) {
        deleteButton.tintColor = .red
        
        var rightBarButtonItems = [addButton]
        
        if !isDeleteButtonHidden {
            rightBarButtonItems.append(deleteButton)
        }
        
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
    }
}

extension LocationsPagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let height = UIScreen.main.bounds.height - (navigationController?.navigationBar.height ?? 0) - view.safeAreaInsets.top
        
        return CGSize(
            width: collectionView.bounds.width,
            height: height
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .zero
    }
    
}

extension LocationsPagesViewController {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reconfigureNavigationBarItems(with: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        reconfigureNavigationBarItems(with: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        configureNavBarItems(isDeleteButtonHidden: true)
    }
    
}
