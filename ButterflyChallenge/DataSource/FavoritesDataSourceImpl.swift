//
//  FavoritesManager.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Notification

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}

// MARK: - Protocol

protocol FavoritesDataSource {
    func getFavorites() -> [FavoriteMovie]
    func addFavorite(_ movie: FavoriteMovie)
    func removeFavorite(movieId: Int)
    func isFavorite(movieId: Int) -> Bool
}

// MARK: - Favorite Movie Model

struct FavoriteMovie: Codable, Identifiable, Equatable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let addedDate: Date
    
    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)")
    }
    
    // Convert from Movie
    init(from movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.addedDate = Date()
    }
    
    // Convert from MovieDetail
    init(from movie: MovieDetail) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.addedDate = Date()
    }
    
    // Direct init
    init(id: Int, title: String, overview: String, posterPath: String?, backdropPath: String?, releaseDate: String?, voteAverage: Double, voteCount: Int, addedDate: Date) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.addedDate = addedDate
    }
}

// MARK: - Implementation using UserDefaults

final class FavoritesDataSourceImpl: FavoritesDataSource {
    private let userDefaults: UserDefaults
    private let key = "favorites_movies"
    private var favoritesCache: [FavoriteMovie] = []
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.favoritesCache = loadFavorites()
    }
    
    func getFavorites() -> [FavoriteMovie] {
        return favoritesCache.sorted { $0.addedDate > $1.addedDate }
    }
    
    func addFavorite(_ movie: FavoriteMovie) {
        guard !isFavorite(movieId: movie.id) else { return }
        favoritesCache.append(movie)
        saveFavorites()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    func removeFavorite(movieId: Int) {
        favoritesCache.removeAll { $0.id == movieId }
        saveFavorites()
        NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return favoritesCache.contains { $0.id == movieId }
    }

    // MARK: - Private Methods
    
    private func loadFavorites() -> [FavoriteMovie] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([FavoriteMovie].self, from: data)
        } catch {
            print("Failed to load favorites: \(error)")
            return []
        }
    }
    
    private func saveFavorites() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(favoritesCache)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
}
