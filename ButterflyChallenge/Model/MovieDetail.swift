//
//  MovieDetail.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Movie Detail Model

struct MovieDetail: Codable, Identifiable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let runtime: Int?
    let budget: Int
    let revenue: Int
    let status: String
    let tagline: String?
    let adult: Bool
    let video: Bool
    let originalLanguage: String
    let originalTitle: String
    let genres: [Genre]
    let productionCompanies: [ProductionCompany]
    let homepage: String?
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }
    
    var formattedRuntime: String? {
        guard let runtime = runtime, runtime > 0 else { return nil }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "movie_detail.runtime.hours_minutes".localized(with: [String(hours), String(minutes)])
        } else {
            return "movie_detail.runtime.minutes".localized(with: minutes)
        }
    }
    
    var formattedBudget: String? {
        guard budget > 0 else { return nil }
        return formatCurrency(budget)
    }
    
    var formattedRevenue: String? {
        guard revenue > 0 else { return nil }
        return formatCurrency(revenue)
    }
    
    var releaseYear: String? {
        guard let releaseDate = releaseDate else { return nil }
        return String(releaseDate.prefix(4))
    }
    
    private func formatCurrency(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case runtime
        case budget
        case revenue
        case status
        case tagline
        case adult
        case video
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case genres
        case productionCompanies = "production_companies"
        case homepage
    }
}

// MARK: - Supporting Models

struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
}

struct ProductionCompany: Codable, Identifiable {
    let id: Int
    let name: String
    let logoPath: String?
    let originCountry: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }
}
