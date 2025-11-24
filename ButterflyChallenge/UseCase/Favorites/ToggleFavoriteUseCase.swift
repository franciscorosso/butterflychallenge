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
    private let repository: FavoritesRepository
    
    init(repository: FavoritesRepository) {
        self.repository = repository
    }
    
    func execute(movie: FavoriteMovie) -> Bool {
        if isFavorite(movieId: movie.id) {
            repository.removeFavorite(movieId: movie.id)
            return false
        } else {
            repository.addFavorite(movie)
            return true
        }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return repository.isFavorite(movieId: movieId)
    }
}
