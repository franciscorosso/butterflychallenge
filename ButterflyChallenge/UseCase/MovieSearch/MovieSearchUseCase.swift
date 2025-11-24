//
//  SearchMoviesUseCase.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol MovieSearchUseCase {
    func execute(query: String, page: Int) async throws -> MovieSearchResponse
}

// MARK: - Implementation

final class MovieSearchUseCaseImpl: MovieSearchUseCase {
    private let repository: MoviesRepository
    
    init(repository: MoviesRepository) {
        self.repository = repository
    }
    
    func execute(query: String, page: Int = 1) async throws -> MovieSearchResponse {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw MoviesDatasourceError.invalidURL
        }
        
        return try await repository.searchMovies(query: query, page: page)
    }
}
