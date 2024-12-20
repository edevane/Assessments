//
//  CatViewController.swift
//  Assesment
//
//  Created by Edevane Tan on 19/12/2024.
//

import UIKit
import SwiftUI
import RxSwift

class CatViewController: UIViewController {

    var viewModel: CatViewModelContract?
    var mainCollectionView: UICollectionView?
    var searchBar: UISearchBar?
    var disposeBag = DisposeBag()

    private enum CatCollectionViewLayout: Int, CaseIterable {
        case searchResult
        case featuredCats
        case favouritedCats
    }

    init(viewModel: CatViewModelContract) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        setupSearchBar()
        setupCollectionView()
        loadData()
    }

    private func loadData() {
        Task {
            await viewModel?.fetchCat()
            viewModel?.populateFeaturedCats()
            viewModel?.populateFavouritedCats()
            DispatchQueue.main.async {
                self.mainCollectionView?.reloadData()
            }
        }
    }

    func setupSearchBar() {
        self.searchBar = UISearchBar()
        guard let searchBar else {
            return
        }
        searchBar.delegate = self
        searchBar.showsBookmarkButton = false
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        view.addSubview(searchBar)
        let margin = view.layoutMarginsGuide
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 56).isActive = true
        setupSearchRx()
    }

    func setupCollectionView() {
        self.mainCollectionView = UICollectionView(frame: CGRect.zero,
                                                   collectionViewLayout: UICollectionViewFlowLayout.init())
        guard let mainCollectionView,
              let searchBar else {
            return
        }
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.collectionViewLayout = self.createCompositionalLayout()
        view.addSubview(mainCollectionView)
        mainCollectionView.translatesAutoresizingMaskIntoConstraints = false
        mainCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mainCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mainCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mainCollectionView.register(UINib(nibName: "ListCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: ListCollectionViewCell.cellIdentifier)
        mainCollectionView.register(UINib(nibName: "FeaturedCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: FeaturedCollectionViewCell.cellIdentifier)
        mainCollectionView.register(HeaderCollectionReusableView.self,
                                    forSupplementaryViewOfKind: HeaderCollectionReusableView.reuseIdentifier,
                                    withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier)
        mainCollectionView.keyboardDismissMode = .onDrag
    }

    // swiftlint:disable line_length function_body_length
    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] (section, layoutEnvironment) -> NSCollectionLayoutSection? in
            let actualSection = (self?.viewModel?.searchResult.count ?? 0) > 0 ? section : section + 1
            if let sectionType = CatCollectionViewLayout(rawValue: actualSection) {
                switch sectionType {
                case .searchResult, .favouritedCats:
                    let item = NSCollectionLayoutItem(layoutSize:
                                                        NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                               heightDimension: .fractionalHeight(1)))
                    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0)

                    var config = UICollectionLayoutListConfiguration(appearance: .plain)
                    if sectionType == .favouritedCats {
                        config.trailingSwipeActionsConfigurationProvider = { indexPath in
                            let del = UIContextualAction(style: .destructive, title: "Remove Favourite") { [weak self] _, _, completion in
                                self?.removeFavouriteCat(at: indexPath)
                                completion(true)
                            }
                            return UISwipeActionsConfiguration(actions: [del])
                        }
                    }

                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(50)),
                        elementKind: HeaderCollectionReusableView.reuseIdentifier,
                        alignment: .topLeading
                    )
                    sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

                    let section = NSCollectionLayoutSection.list(using: config,
                                                                 layoutEnvironment: layoutEnvironment)
                    section.boundarySupplementaryItems = [sectionHeader]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16)
                    return section
                case .featuredCats:
                    let item = NSCollectionLayoutItem(layoutSize:
                                                        NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                               heightDimension: .fractionalHeight(1)))

                    let group = NSCollectionLayoutGroup.vertical(layoutSize:
                                                                    NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2),
                                                                                           heightDimension: .absolute(250)),
                                                                 subitems: [item])
                    group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)

                    let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                           heightDimension: .absolute(50)),
                        elementKind: HeaderCollectionReusableView.reuseIdentifier,
                        alignment: .topLeading
                    )

                    let section = NSCollectionLayoutSection(group: group)
                    section.orthogonalScrollingBehavior = .groupPaging
                    section.boundarySupplementaryItems = [sectionHeader]
                    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 0)
                    return section
                }
            }
            return nil
        }
    }
    // swiftlint:enable line_length function_body_length

    func removeFavouriteCat(at indexPath: IndexPath) {
        if let viewModel,
           let section = CatCollectionViewLayout(rawValue: indexPath.section) {
            switch section {
            case .favouritedCats:
                let index = viewModel.favouritedCats.index(viewModel.favouritedCats.startIndex,
                                                         offsetBy: indexPath.row)
                let data = viewModel.favouritedCats[index]
                viewModel.removeFavourite(for: data)
                self.mainCollectionView?.reloadData()
            default:
                break
            }
        }
    }

    func refreshData() {
        self.viewModel?.populateFavouritedCats()
        self.mainCollectionView?.reloadData()
    }
}

// MARK: - CollectionView delegate and data source
extension CatViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel else {
            return 0
        }

        var sectionCount = 1
        if viewModel.searchResult.count > 0 {
            sectionCount += 1
        }

        if viewModel.favouritedCats.count > 0 {
            sectionCount += 1
        }

        return sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let actualSection = (viewModel?.searchResult.count ?? 0) > 0 ? section : section + 1
        if let sectionType = CatCollectionViewLayout(rawValue: actualSection) {
            switch sectionType {
            case .searchResult:
                return viewModel?.searchResult.count ?? 0
            case .featuredCats:
                return viewModel?.featuredCats.count ?? 0
            case .favouritedCats:
                return viewModel?.favouritedCats.count ?? 0
            }
        }
        return 0
    }

    // swiftlint:disable:next line_length
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel,
              let sectionType = CatCollectionViewLayout(rawValue:
                                                            viewModel.searchResult.count > 0 ? indexPath.section : indexPath.section + 1 ) else {
            return UICollectionViewCell()
        }

        switch sectionType {
        case .searchResult:
            if let listCell = collectionView
                .dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.cellIdentifier,
                                     for: indexPath) as? ListCollectionViewCell {
                listCell.setupCell(with: viewModel.searchResult[indexPath.row])
                return listCell
            }
        case .featuredCats:
            if let collectionCell = collectionView
                .dequeueReusableCell(withReuseIdentifier: FeaturedCollectionViewCell.cellIdentifier,
                                     for: indexPath) as? FeaturedCollectionViewCell {
                let index = viewModel.featuredCats.index(viewModel.featuredCats.startIndex,
                                                         offsetBy: indexPath.row)
                let data = viewModel.featuredCats[index]
                collectionCell.setupCell(with: data)
                return collectionCell
            }
        case .favouritedCats:
            if let listCell = collectionView
                .dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.cellIdentifier,
                                     for: indexPath) as? ListCollectionViewCell {
                let index = viewModel.favouritedCats.index(viewModel.favouritedCats.startIndex,
                                                           offsetBy: indexPath.row)
                let data = viewModel.favouritedCats[index]
                listCell.setupCell(with: data)
                return listCell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel,
              let section = CatCollectionViewLayout(rawValue:
                                                        viewModel.searchResult.count > 0 ? indexPath.section : indexPath.section + 1 ) else {
            return
        }

        var view: BreedDetailView?
        switch section {
        case .searchResult:
            view = BreedDetailView(data: viewModel.searchResult[indexPath.row],
                                   viewModel: viewModel) { [weak self] in
                self?.refreshData()
            }
        case .featuredCats:
            let index = viewModel.featuredCats.index(viewModel.featuredCats.startIndex,
                                                     offsetBy: indexPath.row)
            let data = viewModel.featuredCats[index]
            view = BreedDetailView(data: data, viewModel: viewModel) { [weak self] in
                self?.refreshData()
            }
        case .favouritedCats:
            let index = viewModel.favouritedCats.index(viewModel.favouritedCats.startIndex,
                                                     offsetBy: indexPath.row)
            let data = viewModel.favouritedCats[index]
            view = BreedDetailView(data: data, viewModel: viewModel) { [weak self] in
                self?.refreshData()
            }
        }

        if let view {
            self.present(UIHostingController(rootView: view), animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let section = CatCollectionViewLayout(rawValue:
                                                        (viewModel?.searchResult.count ?? 0) > 0 ? indexPath.section : indexPath.section + 1 ),
              let headerView = collectionView
            .dequeueReusableSupplementaryView(ofKind: HeaderCollectionReusableView.reuseIdentifier,
                                              withReuseIdentifier: HeaderCollectionReusableView.reuseIdentifier,
                                              for: indexPath) as? HeaderCollectionReusableView else {
            return UICollectionReusableView()
        }

        switch section {
        case .searchResult:
            headerView.label.text = "Search Result"
        case .featuredCats:
            headerView.label.text = "Featured Cats"
        case .favouritedCats:
            headerView.label.text = "Favourited Cats"
        }
        return headerView
    }
}
