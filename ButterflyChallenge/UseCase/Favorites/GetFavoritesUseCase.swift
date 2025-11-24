//
//  GetFavoritesUseCase.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol GetFavoritesUseCase {
    func execute() -> [FavoriteMovie]
}

// MARK: - Implementation

final class GetFavoritesUseCaseImpl: GetFavoritesUseCase {
    private let repository: FavoritesRepository
    
    init(repository: FavoritesRepository) {
        self.repository = repository
    }
    
    func execute() -> [FavoriteMovie] {
        return repository.getFavorites()
    }
}
