//
//  CatViewController+UISearchBarDelegate.swift
//  Assesment
//
//  Created by Edevane Tan on 19/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

extension CatViewController: UISearchBarDelegate {

    func setupSearchRx() {
        guard let viewModel,
              let searchBar else {
            return
        }

        searchBar.rx.text.orEmpty
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { query -> Observable<[Cat]> in
                if query.isEmpty {
                    return .just([])
                }
                return viewModel.searchBreed(for: query)
                    .catchAndReturn([])
            }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] data in
                guard let self else {
                    return
                }
                self.viewModel?.searchResult = data
                self.mainCollectionView?.reloadData()
            }
            .disposed(by: disposeBag)
    }
}
