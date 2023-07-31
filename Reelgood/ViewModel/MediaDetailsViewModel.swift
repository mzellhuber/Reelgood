//
//  MediaDetailsViewModel.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 30/07/23.
//

import Combine
import Foundation
import UIKit

class MediaDetailsViewModel: ObservableObject {
    @Published var mediaItem: MediaItemDetails?
    private let imageLoader = ImageLoader()
    @Published var posterImage: UIImage?
    
    init(mediaItem: MediaItemDetails?) {
        self.mediaItem = mediaItem
    }
    
    func loadImage() {
        guard let mediaItem = mediaItem else { return }
        Task {
            if let image = await imageLoader.loadImage(from: mediaItem.poster) {
                DispatchQueue.main.async { [weak self] in
                    self?.posterImage = image
                }
            }
        }
    }
}
