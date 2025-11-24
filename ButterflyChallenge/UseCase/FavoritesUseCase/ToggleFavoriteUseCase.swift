//
//  ToggleFavoriteUseCase.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol ToggleFavoriteUseCase {
    @discardableResult func execute(movie: FavoriteMovie) -> Bool
    func isFavorite(movieId: Int) -> Bool
}

// MARK: - Implementation

final class ToggleFavoriteUseCaseImpl: ToggleFavoriteUseCase {
    private let favoritesDataSource: FavoritesDataSource
    
    init(favoritesDataSource: FavoritesDataSource) {
        self.favoritesDataSource = favoritesDataSource
    }
    
    func execute(movie: FavoriteMovie) -> Bool {
        if isFavorite(movieId: movie.id) {
            favoritesDataSource.removeFavorite(movieId: movie.id)
            return false
        } else {
            favoritesDataSource.addFavorite(movie)
            return true
        }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return favoritesDataSource.isFavorite(movieId: movieId)
    }
}
