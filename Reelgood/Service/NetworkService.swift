//
//  NetworkService.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import Foundation
import Combine

enum NetworkError: Error {
    case invalidURL
    case missingData
    case decodingError(Error)
    case networkError(Error)
    case unknownError(Error)
}

class NetworkService {
    let baseURL = "https://reelgood-bff.vercel.app/api/assessment/"
    
    func fetchMediaItems(ofKind contentKind: ContentKind, page: Int = 1) -> AnyPublisher<MediaItems, NetworkError> {
        guard let url = URL(string: "\(baseURL)browse/\(contentKind.rawValue)s?page=\(page)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }        
        return Future { promise in
            Task {
                do {
                    let mediaItems: MediaItems = try await self.request(url: url)
                    promise(.success(mediaItems))
                } catch {
                    if let networkError = error as? NetworkError {
                        promise(.failure(networkError))
                    } else {
                        promise(.failure(.unknownError(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    func fetchMediaItemDetails(ofKind contentKind: ContentKind, id: Int) -> AnyPublisher<MediaItem, NetworkError> {
        guard let url = URL(string: "\(baseURL)details/\(contentKind.rawValue)/\(id)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        return Future { promise in
            Task {
                do {
                    let mediaItem: MediaItem = try await self.request(url: url)
                    promise(.success(mediaItem))
                } catch {
                    if let networkError = error as? NetworkError {
                        promise(.failure(networkError))
                    } else {
                        promise(.failure(.unknownError(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func request<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            if let urlError = error as? URLError {
                throw NetworkError.networkError(urlError)
            } else {
                throw NetworkError.unknownError(error)
            }
        }
    }
}
