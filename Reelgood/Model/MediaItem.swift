//
//  MediaItem.swift
//  Reelgood
//
//  Created by Melissa Zellhuber on 28/07/23.
//

import Foundation

struct MediaItem: Codable {
    let title: String
    let year: Int
    let ids: IDS
    let id: Int
    let imdb: String
    let contentKind: ContentKind
    let poster: String

    enum CodingKeys: String, CodingKey {
        case title, year, ids, id, imdb
        case contentKind = "content_kind"
        case poster
    }
}

enum ContentKind: String, Codable {
    case movie = "movie"
    case show = "show"
}

struct IDS: Codable {
    let trakt: Int
    let slug: String
    let tvdb: Int? //Only appears in show
    let imdb: String
    let tmdb: Int
    let tvrage: Int? //Only appears in show
}

typealias MediaItems = [MediaItem]
