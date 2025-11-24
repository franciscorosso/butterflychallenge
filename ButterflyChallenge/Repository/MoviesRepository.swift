//
//  MoviesRepository.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation

// MARK: - Protocol

protocol MoviesRepository {
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse
    func getMovieDetail(movieId: Int) async throws -> MovieDetail
}

// MARK: - Implementation

final class MoviesRepositoryImpl: MoviesRepository {
    private let remoteDatasource: MoviesDatasource
    
    init(remoteDatasource: MoviesDatasource) {
        self.remoteDatasource = remoteDatasource
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> MovieSearchResponse {
        return try await remoteDatasource.searchMovies(query: query, page: page)
    }
    
    func getMovieDetail(movieId: Int) async throws -> MovieDetail {
        return try await remoteDatasource.getMovieDetail(movieId: movieId)
    }
}
