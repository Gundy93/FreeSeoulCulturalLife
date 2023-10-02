//
//  ScrapViewController.swift
//  SeoulCulturalLife
//
//  Created by Gundy on 2023/10/02.
//

import UIKit

final class ScrapViewController: EventsViewController {
    
    typealias ScrapDataSource = UICollectionViewDiffableDataSource<Int, Event>
    
    private var scrapCollectionView: UICollectionView?
    private var scrapDataSource: ScrapDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar(Constant.navigationTitle)
        configureCollectionView()
        configureDataSource()
        configureViewHierarchy()
    }
    
    private func configureCollectionView() {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: makeScrapLayout())
        
        collectionView.delegate = self
        collectionView.register(ScrapCell.self,
                                forCellWithReuseIdentifier: Constant.ScrapCellIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        scrapCollectionView = collectionView
    }
    
    private func makeScrapLayout() -> UICollectionViewLayout {
        let provider = {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)))
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3),
                                                   heightDimension: .fractionalHeight(1/3)),
                subitems: [item])
            
            return NSCollectionLayoutSection(group: containerGroup)
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: provider)
    }
    
    private func configureDataSource() {
        guard let scrapCollectionView else { return }
        
        scrapDataSource = ScrapDataSource(collectionView: scrapCollectionView) { collectionView, indexPath, event in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.ScrapCellIdentifier,
                                                                for: indexPath) as? ScrapCell else {
                return ScrapCell()
            }
            let dateText = DateFormatter.shared.dateString(event.startDate,
                                                           event.endDate)
            
            cell.removeImage()
            cell.setText(title: event.title, date: dateText)
            Task { [weak self] in
                cell.setTitleImage(image: await self?.loadImage(url: event.imageLink),
                                   title: event.title) 
            }
            
            return cell
        }
    }
    
    private func configureViewHierarchy() {
        let safeArea = view.safeAreaLayoutGuide
        guard let scrapCollectionView else { return }
        
        view.addSubview(scrapCollectionView)
        NSLayoutConstraint.activate([
            scrapCollectionView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrapCollectionView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            scrapCollectionView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrapCollectionView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
}

extension ScrapViewController: UICollectionViewDelegate {}

extension ScrapViewController {
    
    enum Constant {
        
        static let navigationTitle: String = "스크랩"
        static let ScrapCellIdentifier: String = "ScrapCell"
    }
}