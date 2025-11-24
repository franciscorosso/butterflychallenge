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
            debugPrint("Failed to load favorites: \(error)")
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
            debugPrint("Failed to save favorites: \(error)")
        }
    }
}
