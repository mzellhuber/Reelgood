//
//  MediaListViewController.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import UIKit
import Combine

class MediaListViewController: UIViewController {
    // Constants
    private let logoImageName = "Logo"
    private let underlineViewHeight: CGFloat = 2
    private let underlineViewWidthOffset: CGFloat = 10
    private let underlineViewXOffset: CGFloat = 5
    private let backgroundColorHex = "#081118"
    private let underlineColorHex = "00DC89"
    
    private var collectionView: UICollectionView!
    private var viewModel: MediaListViewModel
    private var cancellables = Set<AnyCancellable>()
    private var segmentedControl: UISegmentedControl!
    private var underlineView: UIView!
    
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    init(viewModel: MediaListViewModel = MediaListViewModel(contentKind: .movie)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // Provide a default implementation instead of fatalError
        self.viewModel = MediaListViewModel(contentKind: .movie)
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupStackView()
        setupSegmentedControl()
        setupUnderlineView()
        setupCollectionView()
        setupViewModelBinding()
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(hex: backgroundColorHex)
    }
    
    private func setupStackView() {
        // Create a horizontal stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        
        // Add logo to the stack view
        guard let logo = UIImage(named: logoImageName) else {
            print("Failed to load logo image")
            return
        }
        let imageView = UIImageView(image: logo)
        stackView.addArrangedSubview(imageView)
        
        // Set the stack view as the title view
        self.navigationItem.titleView = stackView
    }
    
    private func setupSegmentedControl() {
        // Create the segmented control
        segmentedControl = UISegmentedControl(items: ["Movies", "TV Shows"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.backgroundColor = UIColor(hex: backgroundColorHex)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.selectedSegmentTintColor = .clear
        
        // Add segmented control to the stack view
        if let stackView = self.navigationItem.titleView as? UIStackView {
            stackView.addArrangedSubview(segmentedControl)
        }
    }
    
    private func setupUnderlineView() {
        // Create the underline view
        underlineView = UIView()
        underlineView.backgroundColor = UIColor(hex: underlineColorHex)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addSubview(underlineView)
        
        // Position and size the underline view
        NSLayoutConstraint.activate([
            underlineView.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: underlineViewHeight)
        ])
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        
        // Calculate the width for each item
        let width = (view.frame.size.width - 10) / 2
        layout.itemSize = CGSize(width: width, height: width)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        collectionView.register(MediaItemCell.self, forCellWithReuseIdentifier: "MediaItemCell")
        collectionView.backgroundColor = UIColor(hex: backgroundColorHex)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupViewModelBinding() {
        viewModel.$mediaItems
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUnderlinePosition()
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let contentKind: ContentKind = sender.selectedSegmentIndex == 0 ? .movie : .show
        viewModel = MediaListViewModel(contentKind: contentKind)
        setupViewModelBinding()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.updateUnderlinePosition()
        }
        
        // Scroll to the top of the collection view
        collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func updateUnderlinePosition() {
        underlineView.removeFromSuperview()
        underlineView = UIView()
        underlineView.backgroundColor = UIColor(hex: underlineColorHex)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addSubview(underlineView)
        
        let segmentIndex = CGFloat(segmentedControl.selectedSegmentIndex)
        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let underlineWidth = segmentWidth - underlineViewWidthOffset
        let underlineX = segmentWidth * segmentIndex + underlineViewXOffset + (segmentWidth - underlineWidth) / 2
        
        NSLayoutConstraint.activate([
            underlineView.bottomAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: underlineViewHeight),
            underlineView.widthAnchor.constraint(equalToConstant: underlineWidth),
            underlineView.leadingAnchor.constraint(equalTo: segmentedControl.leadingAnchor, constant: underlineX)
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension MediaListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCell", for: indexPath) as? MediaItemCell else {
            print("Failed to dequeue a MediaItemCell")
            return UICollectionViewCell()
        }
        let mediaItem = viewModel.mediaItems[indexPath.row]
        cell.title = mediaItem.title
        cell.year = mediaItem.year
        Task {
            if let image = await loadImage(from: mediaItem.poster) {
                DispatchQueue.main.async {
                    cell.posterImageView.image = image
                }
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension MediaListViewController: UICollectionViewDelegate {
    // Implement UICollectionViewDelegate methods here if needed
}

extension MediaListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow

            return CGSize(width: widthPerItem, height: widthPerItem * 1.5)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension MediaListViewController {
    private func loadImage(from url: String) async -> UIImage? {
        guard let url = URL(string: url) else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
}

extension MediaListViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            // If you're prefetching the last item, fetch the next page of items.
            if indexPath.row == viewModel.mediaItems.count - 1 {
                viewModel.fetchNextPage()
            }
        }
    }
}
