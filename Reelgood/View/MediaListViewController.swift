//
//  MediaListViewController.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import UIKit
import Combine

class MediaListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    private var collectionView: UICollectionView!
    private var viewModel: MediaListViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: MediaListViewModel = MediaListViewModel(contentKind: .movie)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        // TODO: Configure the layout for a grid

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MediaItemCell.self, forCellWithReuseIdentifier: MediaItemCell.reuseIdentifier)

        view.addSubview(collectionView)

        viewModel.$mediaItems
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.mediaItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaItemCell.reuseIdentifier, for: indexPath) as! MediaItemCell
        let mediaItem = viewModel.mediaItems[indexPath.row]
        cell.title = mediaItem.title
        return cell
    }
}
