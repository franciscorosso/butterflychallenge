//
//  MoviesViewModel.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Observation

@Observable
final class MoviesViewModel {
    private let searchMoviesUseCase: SearchMoviesUseCase
    private var searchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    
    var movies: [Movie] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String?
    var currentPage: Int = 0
    var totalPages: Int = 0
    var totalResults: Int = 0
    
    init(searchMoviesUseCase: SearchMoviesUseCase) {
        self.searchMoviesUseCase = searchMoviesUseCase
    }
    
    var canLoadMore: Bool {
        return currentPage < totalPages && !isLoading && !isLoadingMore
    }
    
    @MainActor
    func searchMovies() async {
        searchTask?.cancel()
        
        guard !searchQuery.isEmpty else {
            movies = []
            errorMessage = nil
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500)) // Debounce the search for 0.5 seconds.

            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            
            do {
                let response = try await searchMoviesUseCase.execute(query: searchQuery, page: 1)

                guard !Task.isCancelled else {
                    isLoading = false
                    return
                }
                
                movies = response.results
                currentPage = response.page
                totalPages = response.totalPages
                totalResults = response.totalResults
            } catch let error as MoviesDatasourceError {
                errorMessage = error.errorDescription
                movies = []
            } catch {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                movies = []
            }
            
            isLoading = false
        }
        
        await searchTask?.value
    }

    @MainActor
    func clearSearch() {
        searchTask?.cancel()
        loadMoreTask?.cancel()
        searchQuery = ""
        movies = []
        errorMessage = nil
        currentPage = 0
        totalPages = 0
        totalResults = 0
        isLoading = false
        isLoadingMore = false
    }
    
    @MainActor
    func loadMoreMoviesIfNeeded(_ movie: Movie) async {
        guard movie.id == movies.last?.id else { return }
        await loadMoreMovies()
    }

    @MainActor
    private func loadMoreMovies() async {
        guard canLoadMore else { return }
        
        // Prevent multiple simultaneous load more requests
        guard loadMoreTask == nil || loadMoreTask?.isCancelled == true else { return }
        
        isLoadingMore = true
        errorMessage = nil
        
        loadMoreTask = Task {
            defer { loadMoreTask = nil }
            
            do {
                let nextPage = currentPage + 1
                let response = try await searchMoviesUseCase.execute(query: searchQuery, page: nextPage)
                
                guard !Task.isCancelled else {
                    isLoadingMore = false
                    return
                }
                
                movies.append(contentsOf: response.results)
                currentPage = response.page
                totalPages = response.totalPages
                totalResults = response.totalResults
            } catch let error as MoviesDatasourceError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            
            isLoadingMore = false
        }
    }
}
