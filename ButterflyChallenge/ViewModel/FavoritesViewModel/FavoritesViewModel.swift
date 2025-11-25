//
//  FavoritesViewModel.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Observation

@Observable
final class FavoritesViewModel {
    private let getFavoritesUseCase: GetFavoritesUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    
    var favorites: [FavoriteMovie] = []
    var isLoading = false
    
    init(getFavoritesUseCase: GetFavoritesUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.getFavoritesUseCase = getFavoritesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
    }

    @MainActor
    func loadFavorites() {
        isLoading = true
        favorites = getFavoritesUseCase.execute()
        isLoading = false
    }
    
    @MainActor
    func removeFavorite(_ movie: FavoriteMovie) {
        toggleFavoriteUseCase.execute(movie: movie)
        loadFavorites()
    }
}
