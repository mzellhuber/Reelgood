//
//  MediaItemCell.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 29/07/23.
//

import UIKit

class MediaItemCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaItemCell"
    
    var title: String? {
        didSet {
            updateTitleLabel()
        }
    }
    
    var year: Int? {
        didSet {
            updateTitleLabel()
        }
    }
    
    private func updateTitleLabel() {
        let titleText = title ?? ""
        let yearText = year != nil ? " (\(year!))" : ""
        titleLabel.text = titleText + yearText
    }
    
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white.withAlphaComponent(0.4)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackView = UIStackView(arrangedSubviews: [posterImageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
