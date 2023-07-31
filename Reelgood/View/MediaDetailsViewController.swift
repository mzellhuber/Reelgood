//
//  MediaDetailsViewController.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 30/07/23.
//

import UIKit
import Combine

class MediaDetailsViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()

    // MARK: Properties
    @Published var mediaItem: MediaItemDetails? {
        didSet {
            updateUI()
        }
    }
    
    var viewModel: MediaDetailsViewModel! {
            didSet {
                viewModel.$mediaItem
                    .sink { [weak self] mediaItem in
                        DispatchQueue.main.async {
                            self?.mediaItem = mediaItem
                            self?.updateUI()
                        }
                    }
                    .store(in: &cancellables)
            }
        }
    
    let imageLoader = ImageLoader()
    
    // MARK: UI Elements
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let lengthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        viewModel.loadImage()
    }
    
    // MARK: Setup Views
    private func setupViews() {
        view.backgroundColor = UIColor(hex: "#081118").withAlphaComponent(0.8)
        
        let sheetView = UIView()
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        sheetView.backgroundColor = UIColor(hex: "#081118").withAlphaComponent(0.8)
        view.addSubview(sheetView)
        
        sheetView.addSubview(closeButton)
        sheetView.addSubview(posterImageView)
        sheetView.addSubview(titleLabel)
        sheetView.addSubview(yearLabel)
        sheetView.addSubview(lengthLabel)
        sheetView.addSubview(overviewLabel)
        
        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            
            posterImageView.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 24),
            posterImageView.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 24),
            posterImageView.heightAnchor.constraint(equalToConstant: 200),
            posterImageView.widthAnchor.constraint(equalToConstant: 150),
            
            titleLabel.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            yearLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            yearLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            
            lengthLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 8),
            lengthLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: 16),
            lengthLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            
            overviewLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            overviewLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 24),
            overviewLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -24),
            overviewLabel.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: Update UI
    private func updateUI() {
        guard let mediaItem = mediaItem else { return }

        titleLabel.text = mediaItem.title
        yearLabel.text = "\(mediaItem.year)"
        // Convert runtime to hours and minutes
        let hours = mediaItem.runtime / 60
        let minutes = mediaItem.runtime % 60
        lengthLabel.text = "\(hours)h \(minutes)m"
        overviewLabel.text = mediaItem.overview

        Task {
            if let image = await imageLoader.loadImage(from: mediaItem.poster) {
                DispatchQueue.main.async {
                    self.posterImageView.image = image
                }
            }
        }
    }
    
    // MARK: Button Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
