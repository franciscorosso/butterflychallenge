//
//  MoviesLocalDataSourceSwiftData.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import SwiftData

// MARK: - Protocol

protocol MoviesLocalDataSource {
    func getCachedSearchResults(query: String, page: Int) -> MovieSearchResponse?
    func cacheSearchResults(response: MovieSearchResponse)
    func getCachedMovieDetail(movieId: Int) -> MovieDetail?
    func cacheMovieDetail(movieId: Int, detail: MovieDetail)
    func getAllCachedMovies(query: String?) -> [Movie]
}

// MARK: - SwiftData Implementation

final class MoviesLocalDataSourceImpl: MoviesLocalDataSource {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelContext = ModelContext(modelContainer)
        
        // Auto-clear expired cache on init
        clearExpiredCache()
    }
    
    // MARK: - Search Results Cache
    
    func getCachedSearchResults(query: String, page: Int) -> MovieSearchResponse? {
        // Get all cached movies and filter by query
        let allCachedMovies = getAllCachedMovies(query: query)
        
        guard !allCachedMovies.isEmpty else {
            return nil
        }
        
        // Simulate pagination
        let pageSize = 20
        let startIndex = (page - 1) * pageSize
        
        guard startIndex < allCachedMovies.count else {
            return nil
        }
        
        let endIndex = min(startIndex + pageSize, allCachedMovies.count)
        let pageResults = Array(allCachedMovies[startIndex..<endIndex])
        
        let totalPages = (allCachedMovies.count + pageSize - 1) / pageSize
        
        return MovieSearchResponse(
            page: page,
            results: pageResults,
            totalPages: totalPages,
            totalResults: allCachedMovies.count
        )
    }
    
    func cacheSearchResults(response: MovieSearchResponse) {
        // Store each movie individually
        for movie in response.results {
            // Check if movie already exists
            let descriptor = FetchDescriptor<CachedMovieEntity>(
                predicate: #Predicate { $0.id == movie.id }
            )
            
            if let existingMovie = try? modelContext.fetch(descriptor).first {
                // Update existing movie timestamp
                existingMovie.timestamp = Date()
                updateMovieEntity(existingMovie, from: movie)
            } else {
                // Insert new movie
                let cachedMovie = CachedMovieEntity(from: movie)
                modelContext.insert(cachedMovie)
            }
        }
        
        // Save changes
        do {
            try modelContext.save()
            debugPrint(">>> Saved \(response.results.count) movies to SwiftData cache")
        } catch {
            debugPrint(">>> Failed to save movies to cache: \(error)")
        }
    }
    
    // MARK: - Movie Detail Cache
    
    func getCachedMovieDetail(movieId: Int) -> MovieDetail? {
        let descriptor = FetchDescriptor<CachedMovieDetailEntity>(
            predicate: #Predicate { $0.id == movieId }
        )
        
        guard let cachedDetail = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        // Check if expired
        guard !cachedDetail.isExpired else {
            // Delete expired detail
            modelContext.delete(cachedDetail)
            try? modelContext.save()
            return nil
        }
        
        return cachedDetail.toMovieDetail()
    }
    
    func cacheMovieDetail(movieId: Int, detail: MovieDetail) {
        let descriptor = FetchDescriptor<CachedMovieDetailEntity>(
            predicate: #Predicate { $0.id == movieId }
        )
        
        // Delete existing if found
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }
        
        // Insert new detail
        let cachedDetail = CachedMovieDetailEntity(from: detail)
        modelContext.insert(cachedDetail)
        
        // Save
        do {
            try modelContext.save()
            debugPrint(">>> Saved movie detail to SwiftData cache: \(movieId)")
        } catch {
            debugPrint(">>> Failed to save movie detail: \(error)")
        }
    }
    
    // MARK: - Get All Cached Movies
    
    func getAllCachedMovies(query: String?) -> [Movie] {
        var allMovies: [Movie] = []
        
        // Fetch all cached movies
        let descriptor = FetchDescriptor<CachedMovieEntity>(
            sortBy: [SortDescriptor(\.popularity, order: .reverse)]
        )
        
        guard let cachedMovies = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        // Filter out expired and convert to Movie
        for cachedMovie in cachedMovies {
            guard !cachedMovie.isExpired else { continue }
            allMovies.append(cachedMovie.toMovie())
        }
        
        // Filter by query if provided
        if let query = query, !query.isEmpty {
            let lowercasedQuery = query.lowercased()
            allMovies = allMovies.filter { movie in
                movie.title.lowercased().contains(lowercasedQuery) ||
                movie.originalTitle.lowercased().contains(lowercasedQuery)
            }
        }
        
        debugPrint(">>> Found \(allMovies.count) cached movies" + (query != nil ? " matching '\(query!)'" : ""))
        
        return allMovies
    }
    
    // MARK: - Cache Management
    
    func clearExpiredCache() {
        // Clear expired movies
        let movieDescriptor = FetchDescriptor<CachedMovieEntity>()
        if let allMovies = try? modelContext.fetch(movieDescriptor) {
            let expiredMovies = allMovies.filter { $0.isExpired }
            for movie in expiredMovies {
                modelContext.delete(movie)
            }
            if !expiredMovies.isEmpty {
                debugPrint(">>> Cleared \(expiredMovies.count) expired movies")
            }
        }
        
        // Clear expired details
        let detailDescriptor = FetchDescriptor<CachedMovieDetailEntity>()
        if let allDetails = try? modelContext.fetch(detailDescriptor) {
            let expiredDetails = allDetails.filter { $0.isExpired }
            for detail in expiredDetails {
                modelContext.delete(detail)
            }
            if !expiredDetails.isEmpty {
                debugPrint(">>> Cleared \(expiredDetails.count) expired movie details")
            }
        }
        
        try? modelContext.save()
    }
    
    func clearAllCache() {
        // Delete all movies
        let movieDescriptor = FetchDescriptor<CachedMovieEntity>()
        if let allMovies = try? modelContext.fetch(movieDescriptor) {
            for movie in allMovies {
                modelContext.delete(movie)
            }
        }
        
        // Delete all details
        let detailDescriptor = FetchDescriptor<CachedMovieDetailEntity>()
        if let allDetails = try? modelContext.fetch(detailDescriptor) {
            for detail in allDetails {
                modelContext.delete(detail)
            }
        }
        
        try? modelContext.save()
        debugPrint(">>> Cleared all cache")
    }
    
    // MARK: - Private Methods
    
    private func updateMovieEntity(_ entity: CachedMovieEntity, from movie: Movie) {
        entity.title = movie.title
        entity.overview = movie.overview
        entity.posterPath = movie.posterPath
        entity.backdropPath = movie.backdropPath
        entity.releaseDate = movie.releaseDate
        entity.voteAverage = movie.voteAverage
        entity.voteCount = movie.voteCount
        entity.popularity = movie.popularity
        entity.adult = movie.adult
        entity.video = movie.video
        entity.originalLanguage = movie.originalLanguage
        entity.originalTitle = movie.originalTitle
        entity.genreIds = movie.genreIds
    }
}
