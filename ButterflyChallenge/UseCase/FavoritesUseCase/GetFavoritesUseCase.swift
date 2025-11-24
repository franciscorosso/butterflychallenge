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
    private let favoritesDataSource: FavoritesDataSource
    
    init(favoritesDataSource: FavoritesDataSource) {
        self.favoritesDataSource = favoritesDataSource
    }
    
    func execute() -> [FavoriteMovie] {
        return favoritesDataSource.getFavorites()
    }
}
