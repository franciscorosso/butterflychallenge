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
        
        do {
            let detail = try await getMovieDetailUseCase.execute(movieId: movieId)
            movieDetail = detail
            isFavorite = toggleFavoriteUseCase.isFavorite(movieId: movieId)
        } catch let error as MoviesDatasourceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "error.unexpected".localized(with: error.localizedDescription)
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
}
