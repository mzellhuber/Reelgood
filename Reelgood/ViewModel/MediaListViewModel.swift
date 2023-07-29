//
//  MediaListViewModel.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import Combine
import Foundation

class MediaListViewModel {
    private var networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    private var contentKind: ContentKind
    
    // Outputs that the view controller can subscribe to
    @Published var mediaItems: [MediaItem] = []
    @Published var error: NetworkError?

    init(contentKind: ContentKind, networkService: NetworkService = NetworkService()) {
        self.contentKind = contentKind
        self.networkService = networkService
        fetchMediaItems(ofKind: contentKind)
    }
    
    func fetchMediaItems(ofKind contentKind: ContentKind, page: Int = 1) {
        networkService.fetchMediaItems(ofKind: contentKind, page: page)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.error = error
                    }
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] mediaItems in
                DispatchQueue.main.async {
                    self?.mediaItems = mediaItems
                }
            })
            .store(in: &cancellables)
    }
}
