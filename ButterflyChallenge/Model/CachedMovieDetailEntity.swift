//
//  CachedMovieDetailEntity.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import SwiftData

@Model
final class CachedMovieDetailEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var overview: String
    var posterPath: String?
    var backdropPath: String?
    var releaseDate: String?
    var voteAverage: Double
    var voteCount: Int
    var popularity: Double
    var runtime: Int?
    var budget: Int
    var revenue: Int
    var status: String
    var tagline: String?
    var adult: Bool
    var video: Bool
    var originalLanguage: String
    var originalTitle: String
    var homepage: String?
    var timestamp: Date

    // Store as JSON strings for complex types
    var genresJSON: String?
    var productionCompaniesJSON: String?

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
        runtime: Int?,
        budget: Int,
        revenue: Int,
        status: String,
        tagline: String?,
        adult: Bool,
        video: Bool,
        originalLanguage: String,
        originalTitle: String,
        homepage: String?,
        genresJSON: String?,
        productionCompaniesJSON: String?,
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
        self.runtime = runtime
        self.budget = budget
        self.revenue = revenue
        self.status = status
        self.tagline = tagline
        self.adult = adult
        self.video = video
        self.originalLanguage = originalLanguage
        self.originalTitle = originalTitle
        self.homepage = homepage
        self.genresJSON = genresJSON
        self.productionCompaniesJSON = productionCompaniesJSON
        self.timestamp = timestamp
    }

    // Convert from MovieDetail
    convenience init(from detail: MovieDetail, timestamp: Date = Date()) {
        let genresJSON = try? JSONEncoder().encode(detail.genres)
        let companiesJSON = try? JSONEncoder().encode(detail.productionCompanies)

        self.init(
            id: detail.id,
            title: detail.title,
            overview: detail.overview,
            posterPath: detail.posterPath,
            backdropPath: detail.backdropPath,
            releaseDate: detail.releaseDate,
            voteAverage: detail.voteAverage,
            voteCount: detail.voteCount,
            popularity: detail.popularity,
            runtime: detail.runtime,
            budget: detail.budget,
            revenue: detail.revenue,
            status: detail.status,
            tagline: detail.tagline,
            adult: detail.adult,
            video: detail.video,
            originalLanguage: detail.originalLanguage,
            originalTitle: detail.originalTitle,
            homepage: detail.homepage,
            genresJSON: genresJSON != nil ? String(data: genresJSON!, encoding: .utf8) : nil,
            productionCompaniesJSON: companiesJSON != nil ? String(data: companiesJSON!, encoding: .utf8) : nil,
            timestamp: timestamp
        )
    }

    // Convert to MovieDetail
    func toMovieDetail() -> MovieDetail? {
        var genres: [Genre] = []
        var companies: [ProductionCompany] = []

        if let genresJSON = genresJSON?.data(using: .utf8) {
            genres = (try? JSONDecoder().decode([Genre].self, from: genresJSON)) ?? []
        }

        if let companiesJSON = productionCompaniesJSON?.data(using: .utf8) {
            companies = (try? JSONDecoder().decode([ProductionCompany].self, from: companiesJSON)) ?? []
        }

        return MovieDetail(
            id: id,
            title: title,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: popularity,
            runtime: runtime,
            budget: budget,
            revenue: revenue,
            status: status,
            tagline: tagline,
            adult: adult,
            video: video,
            originalLanguage: originalLanguage,
            originalTitle: originalTitle,
            genres: genres,
            productionCompanies: companies,
            homepage: homepage
        )
    }

    // Check if cache is expired (1 hour)
    var isExpired: Bool {
        let cacheExpirationTime: TimeInterval = 3600 // 1 hour
        return Date().timeIntervalSince(timestamp) > cacheExpirationTime
    }
}
