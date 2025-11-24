//
//  SearchMoviesUseCase.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol SearchMoviesUseCase {
    func execute(query: String, page: Int) async throws -> MovieSearchResponse
}

// MARK: - Implementation

final class SearchMoviesUseCaseImpl: SearchMoviesUseCase {
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
