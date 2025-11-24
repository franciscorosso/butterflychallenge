//
//  CachedMovieEntity.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import SwiftData

// MARK: - SwiftData Models

@Model
final class CachedMovieEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: String?
    var voteAverage: Double
    var voteCount: Int
    var popularity: Double
    var adult: Bool
    var video: Bool
    var originalLanguage: String
    var originalTitle: String
    var genreIds: [Int]
    var timestamp: Date
    
    init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        releaseDate: String?,
        voteAverage: Double,
        voteCount: Int,
        popularity: Double,
        adult: Bool,
        video: Bool,
        originalLanguage: String,
        originalTitle: String,
        genreIds: [Int],
        timestamp: Date
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.adult = adult
        self.video = video
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.genreIds = genreIds
        self.timestamp = timestamp
    }
    
    // Convert from Movie
    convenience init(from movie: Movie, timestamp: Date = Date()) {
        self.init(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            popularity: movie.popularity,
            adult: movie.adult,
            video: movie.video,
            originalLanguage: movie.originalLanguage,
            originalTitle: movie.originalTitle,
            genreIds: movie.genreIds,
            timestamp: timestamp
        )
    }
    
    // Convert to Movie
    func toMovie() -> Movie {
        return Movie(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            adult: adult,
            video: video,
            originalLanguage: originalLanguage,
            originalTitle: originalTitle,
            genreIds: genreIds
        )
    }
    
    // Check if cache is expired (1 hour)
    var isExpired: Bool {
        let cacheExpirationTime: TimeInterval = 3600 // 1 hour
        return Date().timeIntervalSince(timestamp) > cacheExpirationTime
    }
}
