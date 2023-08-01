//
//  ReelgoodTests.swift
//  ReelgoodTests
//
//  Created by Melissa Zellhuber on 31/07/23.
//

@testable import Reelgood
import XCTest
import Combine

class MediaListViewModelTests: XCTestCase {
    var viewModel: MediaListViewModel!
    var mockNetworkService: MockNetworkService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = MediaListViewModel(contentKind: .movie, networkService: mockNetworkService)
    }
    
    func testFetchMediaItems() {
        let expectation = XCTestExpectation(description: "Media items fetched")
        
        viewModel.$mediaItems.sink { mediaItems in
            if !mediaItems.isEmpty {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        viewModel.fetchMediaItems(ofKind: .movie)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchMediaItemDetails() {
        let expectation = XCTestExpectation(description: "Media item details fetched")
        
        let mediaItem = MediaItem(title: "Test", year: 2020, ids: IDS(trakt: 1, slug: "test", tvdb: 1, imdb: "test", tmdb: 1, tvrage: 1), id: 1, imdb: "test", contentKind: .movie, poster: "poster.png", details: nil)
        
        viewModel.fetchMediaItemDetails(ofKind: .movie, id: mediaItem.id)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { mediaItemDetails in
                    if mediaItemDetails != nil {
                        expectation.fulfill()
                    }
                  })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPagination() {
        let expectation = XCTestExpectation(description: "Media items fetched for next page")
        
        viewModel.$mediaItems.sink { mediaItems in
            if mediaItems.count == 40 {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        viewModel.fetchMediaItems(ofKind: .movie)
        viewModel.fetchNextPage()
        
        wait(for: [expectation], timeout: 1.0)
    }
}

class MockNetworkService: NetworkService {
    override func fetchMediaItems(ofKind contentKind: ContentKind, page: Int) -> AnyPublisher<[MediaItem], NetworkError> {
        let ids = IDS(trakt: 1, slug: "test", tvdb: 1, imdb: "test", tmdb: 1, tvrage: 1)
        
        var mediaItems: [MediaItem] = []
        
        for _ in 0..<20 {
            let mediaItem = MediaItem(title: "Test", year: 2020, ids: ids, id: 1, imdb: "test", contentKind: contentKind, poster: "poster.png", details: nil)
            mediaItems.append(mediaItem)
        }
        
        return Just(mediaItems)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    override func fetchMediaItemDetails(ofKind contentKind: ContentKind, id: Int) -> AnyPublisher<MediaItemDetails, NetworkError> {
        let ids = IDS(trakt: 1, slug: "test", tvdb: 1, imdb: "test", tmdb: 1, tvrage: 1)
        let mediaItemDetails = MediaItemDetails(title: "Test", year: 2020, ids: ids, tagline: "Test tagline", overview: "Test overview", released: "2020-01-01", runtime: 120, country: "US", trailer: "trailer.mp4", homepage: "https://example.com", status: "Released", rating: 7.5, votes: 1000, commentCount: 100, updatedAt: "2020-01-01T00:00:00Z", language: "en", availableTranslations: ["en"], genres: ["Action"], certification: "PG-13", id: 1, contentKind: "movie", imdb: "test", poster: "poster.png")
        return Just(mediaItemDetails)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
}
