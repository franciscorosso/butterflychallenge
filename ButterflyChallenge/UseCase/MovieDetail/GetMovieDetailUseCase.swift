//
//  GetMovieDetailUseCase.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol GetMovieDetailUseCase {
    func execute(movieId: Int) async throws -> MovieDetail
}

// MARK: - Implementation

final class GetMovieDetailUseCaseImpl: GetMovieDetailUseCase {
    private let repository: MoviesRepository
    
    init(repository: MoviesRepository) {
        self.repository = repository
    }
    
    func execute(movieId: Int) async throws -> MovieDetail {
        return try await repository.getMovieDetail(movieId: movieId)
    }
}
