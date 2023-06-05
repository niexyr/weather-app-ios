//
//  AddNewLocationViewController.swift
//  Weather
//
//  Created by Valery Shamshin on 03.06.2023.
//  Copyright © 2023 Heads and Hands. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwifterSwift
import RxDataSources
import JGProgressHUD

class AddNewLocationViewController: BaseViewController, LoaderPresentable {
    
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchHintLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    
    @IBOutlet private var shadowViewHeightConstraint: NSLayoutConstraint!
    
    private var dataSource: RxTableViewSectionedAnimatedDataSource<AddNewLocationSectionModel>?
    
    private let viewModel: AddNewLocationViewModel
    
    var loader: JGProgressHUD?
    
    init(viewModel: AddNewLocationViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        shadowViewHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }
    
    private func configureView() {
        configureSearchBar()
        configureTableView()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Поиск"
        searchBar.backgroundImage = UIImage()
    }
    
    private func configureTableView() {
        tableView.separatorColor = .clear
        
        tableView.register(nibWithCellClass: AddNewLocationCell.self)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<AddNewLocationSectionModel>(
            configureCell: { _, tableView, indexPath, item in
                switch item {
                case let .location(model):
                    let cell = tableView.dequeueReusableCell(withClass: AddNewLocationCell.self, for: indexPath)
                    cell.configure(with: model)
                    return cell
                }
            }
        )
        
        dataSource.animationConfiguration = .init(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade
        )
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.dataSource = dataSource
    }
    
    private func applySearchState(_ state: AddNewLocationSearchState) {
        tableView.isHidden = !(state.contains(.hasValidSearchText) && state.contains(.hasSomeValidResults))
        searchHintLabel.isHidden = !(state.contains(.hasValidSearchText) && !state.contains(.hasSomeValidResults))
        
        let hintText: String? = {
            switch state {
            case [.hasValidSearchText, .isCurrentlySearching]: return "Ищем локации..."
            case [.hasValidSearchText]: return "Ничего не найдено"
            case [.hasValidSearchText, .failedLastSearchWithError]: return "Поиск завершился с ошибкой"
            default: return nil
            }
        }()
        
        searchHintLabel.text = hintText
    }
    
    private func bind() {
        // MARK: Решение для анимированного изменения инсета контента в таблице, когда появляется клавиатура
        // Стандартный RxKeyboard работает кривовато
        
        let keyboardInfo = RxKeyboard.instance.visibleHeight
            .debounce(.milliseconds(50))
            .withLatestFrom(RxKeyboard.instance.curve.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
            .withLatestFrom(RxKeyboard.instance.duration.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
            .map { args -> (CGFloat, UIView.AnimationCurve, TimeInterval) in
                let (pack1, duration) = args
                let (height, curve) = pack1
                
                return (height, curve ?? .easeOut, duration ?? 0.25)
            }
        
        keyboardInfo
            .drive(
                onNext: { [weak self] keyboardInfo in
                    guard let self = self else {
                        return
                    }
                    
                    let (keyboardHeight, _, duration) = keyboardInfo
                    
                    UIView.animate(
                        withDuration: duration,
                        delay: .zero,
                        options: .curveLinear
                    ) {
                        let bottomInset = max(0, keyboardHeight - self.view.safeAreaInsets.bottom)
                        
                        self.tableView.contentInset.bottom = bottomInset
                        self.tableView.verticalScrollIndicatorInsets.bottom = bottomInset
                        
                        self.view.layoutIfNeeded()
                    }
                }
            )
            .disposed(by: disposeBag)
        
        let input = AddNewLocationViewModel.Input(
            searchText: searchBar.rx.text.asDriver(),
            itemSelected: tableView.rx.itemSelected.asDriver()
        )
        
        let output = viewModel.transform(input: input)
        
        output.sectionModels
            .drive(tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        output.searchState
            .drive(
                onNext: { [weak self] state in
                    self?.applySearchState(state)
                }
            )
            .disposed(by: disposeBag)
        
        output.isBlocking
            .debounce(.milliseconds(25))
            .drive(
                onNext: { [weak self] isBlocking in
                    self?.updateLoader(isEnabled: isBlocking, detailText: nil)
                }
            )
            .disposed(by: disposeBag)
    }

}

extension AddNewLocationViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension AddNewLocationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
}
