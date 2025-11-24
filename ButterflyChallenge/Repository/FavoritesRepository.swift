//
//  FavoritesRepository.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol FavoritesRepository {
    func getFavorites() -> [FavoriteMovie]
    func addFavorite(_ movie: FavoriteMovie)
    func removeFavorite(movieId: Int)
    func isFavorite(movieId: Int) -> Bool
}

// MARK: - Implementation

final class FavoritesRepositoryImpl: FavoritesRepository {
    private let dataSource: FavoritesDataSource
    
    init(dataSource: FavoritesDataSource) {
        self.dataSource = dataSource
    }
    
    func getFavorites() -> [FavoriteMovie] {
        return dataSource.getFavorites()
    }
    
    func addFavorite(_ movie: FavoriteMovie) {
        dataSource.addFavorite(movie)
    }
    
    func removeFavorite(movieId: Int) {
        dataSource.removeFavorite(movieId: movieId)
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return dataSource.isFavorite(movieId: movieId)
    }
}
