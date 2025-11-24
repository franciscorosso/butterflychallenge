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
    private let movieId: Int
    
    // MARK: - State
    var movieDetail: MovieDetail?
    var isLoading = false
    var errorMessage: String?
    
    init(movieId: Int, getMovieDetailUseCase: GetMovieDetailUseCase) {
        self.movieId = movieId
        self.getMovieDetailUseCase = getMovieDetailUseCase
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
        } catch let error as MoviesDatasourceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    @MainActor
    func retry() async {
        await loadMovieDetail()
    }
}
