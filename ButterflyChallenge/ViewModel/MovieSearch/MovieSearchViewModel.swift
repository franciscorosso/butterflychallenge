//
//  MoviesViewModel.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Observation

@Observable
final class MovieSearchViewModel {
    private let searchMoviesUseCase: MovieSearchUseCase
    private let toggleFavoriteUseCase: ToggleFavoriteUseCase
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
    var favoritesVersion: Int = 0
    var canLoadMore: Bool {
        currentPage < totalPages && !isLoading && !isLoadingMore
    }

    init(searchMoviesUseCase: MovieSearchUseCase, toggleFavoriteUseCase: ToggleFavoriteUseCase) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        
        // Listen for favorite changes from other view models
        NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.favoritesVersion += 1
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favoritesDidChange, object: nil)
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return toggleFavoriteUseCase.isFavorite(movieId: movieId)
    }
    
    func toggleFavorite(_ movie: Movie) {
        let favoriteMovie = FavoriteMovie(from: movie)
        toggleFavoriteUseCase.execute(movie: favoriteMovie)
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
                
                applySearchResponse(response)
            } catch let error as MoviesDatasourceError {
                errorMessage = error.errorDescription
                movies = []
            } catch {
                errorMessage = "error.unexpected".localized(with: error.localizedDescription)
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
                
                applySearchResponse(response)
            } catch let error as MoviesDatasourceError {
                errorMessage = error.errorDescription
            } catch {
                errorMessage = "error.unexpected".localized(with: error.localizedDescription)
            }
            
            isLoadingMore = false
        }
    }

    @MainActor
    private func applySearchResponse(_ response: MovieSearchResponse) {
        if response.page == 1 {
            movies = response.results
        } else {
            movies.append(contentsOf: response.results)
        }

        currentPage = response.page
        totalPages = response.totalPages
        totalResults = response.totalResults
    }
}
