//
//  MediaListViewModel.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import Combine

class MediaListViewModel {
    private var networkService: NetworkService
    private var cancellables = Set<AnyCancellable>()
    
    // Outputs that the view controller can subscribe to
    @Published var mediaItems: [MediaItem] = []
    @Published var error: NetworkError?

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchMediaItems(ofKind contentKind: ContentKind, page: Int = 1) {
        networkService.fetchMediaItems(ofKind: contentKind, page: page)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] mediaItems in
                self?.mediaItems = mediaItems
            })
            .store(in: &cancellables)
    }
}
