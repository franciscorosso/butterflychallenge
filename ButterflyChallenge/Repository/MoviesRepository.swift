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
    private let remoteDataSource: MoviesRemoteDatasource
    private let localDataSource: MoviesLocalDataSource
    private let networkMonitor: NetworkMonitor

    init(
        remoteDataSource: MoviesRemoteDatasource,
        localDataSource: MoviesLocalDataSource,
        networkMonitor: NetworkMonitor
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }

    // MARK: - Search Movies (Offline-First)

    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        // 1. Check local cache
        if let cachedResponse = localDataSource.getCachedSearchResults(query: query, page: page) {
            debugPrint(">>> Returning cached search results for query: '\(query)', page: \(page)")

            // If we have cache and network is available, fetch in background to update cache
            if networkMonitor.isConnected {
                Task {
                    await fetchAndCacheSearchResults(query: query, page: page)
                }
            }

            return cachedResponse
        }

        // 2. No cache available - try network
        if networkMonitor.isConnected {
            do {
                debugPrint(">>> Fetching search results from network for query: '\(query)', page: \(page)")
                let response = try await remoteDataSource.searchMovies(query: query, page: page)

                // Cache the response
                localDataSource.cacheSearchResults(response: response)

                return response
            } catch {
                debugPrint(">>> Network error while fetching search results: \(error)")
                throw error
            }
        } else {
            // No cache and no network - throw error
            debugPrint(">>> No cached data and no network connection available")
            throw MoviesRepositoryError.noInternetConnection
        }
    }

    // MARK: - Get Movie Detail (Offline-First)

    func getMovieDetail(movieId: Int) async throws -> MovieDetail {

        // 1. Check local cache
        if let cachedDetail = localDataSource.getCachedMovieDetail(movieId: movieId) {
            debugPrint(">>> Returning cached movie detail for ID: \(movieId)")

            // If we have cache and network is available, fetch in background to update cache
            if networkMonitor.isConnected {
                Task {
                    await fetchAndCacheMovieDetail(movieId: movieId)
                }
            }

            return cachedDetail
        }

        // 2. No cache available - try network
        if networkMonitor.isConnected {
            do {
                debugPrint(">>> Fetching movie detail from network for ID: \(movieId)")
                let detail = try await remoteDataSource.getMovieDetail(movieId: movieId)

                // Cache the detail
                localDataSource.cacheMovieDetail(movieId: movieId, detail: detail)

                return detail
            } catch {
                debugPrint(">>> Network error while fetching movie detail: \(error)")
                throw error
            }
        } else {
            debugPrint(">>> No cached data and no network connection available")
            throw MoviesRepositoryError.noInternetConnection
        }
    }

    // MARK: - Private Methods

    private func fetchAndCacheSearchResults(query: String, page: Int) async {
        do {
            let response = try await remoteDataSource.searchMovies(query: query, page: page)
            localDataSource.cacheSearchResults(response: response)
            debugPrint(">>> Background cache update completed for query: '\(query)', page: \(page)")
        } catch {
            debugPrint(">>> Background cache update failed: \(error)")
        }
    }

    private func fetchAndCacheMovieDetail(movieId: Int) async {
        do {
            let detail = try await remoteDataSource.getMovieDetail(movieId: movieId)
            localDataSource.cacheMovieDetail(movieId: movieId, detail: detail)
            debugPrint(">>> Background cache update completed for movie ID: \(movieId)")
        } catch {
            debugPrint(">>> Background cache update failed: \(error)")
        }
    }
}

// MARK: - Repository Error

enum MoviesRepositoryError: Error {
    case noInternetConnection
    case cacheNotAvailable

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "error.no_internet_connection".localized()
        case .cacheNotAvailable:
            return "error.cache_not_available".localized()
        }
    }
}
