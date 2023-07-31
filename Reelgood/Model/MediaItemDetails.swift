//
//  MediaItemDetails.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import Foundation

struct MediaItemDetails: Codable {
    let title: String
    let year: Int
    let ids: IDS
    let tagline, overview, released: String
    let runtime: Int
    let country: String
    let trailer, homepage: String
    let status: String
    let rating: Double
    let votes, commentCount: Int
    let updatedAt, language: String
    let availableTranslations, genres: [String]
    let certification: String
    let id: Int
    let contentKind: String
    let imdb: String
    var poster: String

    enum CodingKeys: String, CodingKey {
        case title, year, ids, tagline, overview, released, runtime, country, trailer, homepage, status, rating, votes
        case commentCount = "comment_count"
        case updatedAt = "updated_at"
        case language
        case availableTranslations = "available_translations"
        case genres, certification, id
        case contentKind = "content_kind"
        case imdb, poster
    }
}
