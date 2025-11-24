//
//  MovieDetailViewModel.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Observation

@Observable
final class MovieDetailViewModel {
    private let getMovieDetailUseCase: GetMovieDetailUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
    private let movieId: Int
    
    // MARK: - State
    var movieDetail: MovieDetail?
    var isLoading = false
    var errorMessage: String?
    var isOfflineError = false  // New: Track if error is due to offline
    var isFavorite = false
    
    init(movieId: Int, getMovieDetailUseCase: GetMovieDetailUseCase, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.movieId = movieId
        self.getMovieDetailUseCase = getMovieDetailUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.isFavorite = toggleFavoriteUseCase.isFavorite(movieId: movieId)
    }

    // MARK: - Public API
    
    @MainActor
    func loadMovieDetail() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        isOfflineError = false
        
        do {
            let detail = try await getMovieDetailUseCase.execute(movieId: movieId)
            movieDetail = detail
            isFavorite = toggleFavoriteUseCase.isFavorite(movieId: movieId)
        } catch let error as MoviesRepositoryError {
            handleRepositoryError(error)
        } catch let error as MoviesDatasourceError {
            errorMessage = error.errorDescription
            isOfflineError = false
        } catch {
            errorMessage = "error.unexpected".localized(with: error.localizedDescription)
            isOfflineError = false
        }
        
        isLoading = false
    }
    
    @MainActor
    func retry() async {
        await loadMovieDetail()
    }
    
    @MainActor
    func toggleFavorite() {
        guard let movie = movieDetail else { return }
        let favoriteMovie = FavoriteMovie(from: movie)
        isFavorite = toggleFavoriteUseCase.execute(movie: favoriteMovie)
    }
    
    // MARK: - Error Handling
    
    @MainActor
    private func handleRepositoryError(_ error: MoviesRepositoryError) {
        switch error {
        case .noInternetConnection:
            errorMessage = "offline.no_cache.message".localized()
            isOfflineError = true
        case .cacheNotAvailable:
            errorMessage = "error.cache_unavailable".localized()
            isOfflineError = false
        }
    }
}
