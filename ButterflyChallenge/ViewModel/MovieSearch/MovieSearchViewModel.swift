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
    private var networkMonitor: NetworkMonitor

    @ObservationIgnored var totalPages: Int = 0
    @ObservationIgnored var currentPage: Int = 0
    var movies: [Movie] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var errorMessage: String?
    var isOfflineError: Bool = false
    var totalResults: Int = 0
    var favoritesVersion: Int = 0

    var isConnected: Bool {
        networkMonitor.isConnected
    }
    
    var canLoadMore: Bool {
        currentPage < totalPages && !isLoading && !isLoadingMore && isConnected
    }

    init(
        searchMoviesUseCase: MovieSearchUseCase,
        toggleFavoriteUseCase: ToggleFavoriteUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.networkMonitor = networkMonitor

        NotificationCenter.default.addObserver(
            forName: .favoritesDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.favoritesVersion += 1
        }
        
        // Load cached movies on init if offline
        Task { @MainActor in
            if !networkMonitor.isConnected {
                await searchMovies()
            }
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

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500)) // Debounce the search for 0.5 seconds.

            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            isOfflineError = false
            
            do {
                let response = try await searchMoviesUseCase.execute(query: searchQuery, page: 1)

                guard !Task.isCancelled else {
                    isLoading = false
                    return
                }
                
                applySearchResponse(response)
            } catch let error as MoviesRepositoryError {
                handleRepositoryError(error)
            } catch let error as MoviesDatasourceError {
                errorMessage = error.errorDescription
                isOfflineError = false
                movies = []
            } catch {
                errorMessage = "error.unexpected".localized(with: error.localizedDescription)
                isOfflineError = false
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
        isOfflineError = false
        currentPage = 0
        totalPages = 0
        totalResults = 0
        isLoading = false
        isLoadingMore = false
    }

    @MainActor
    func loadMoreMovies(lastMovie: Movie) async {
        guard canLoadMore else { return }
        guard lastMovie.id == movies.last?.id else { return }
        guard loadMoreTask == nil || loadMoreTask?.isCancelled == true else { return }
        
        isLoadingMore = true
        errorMessage = nil
        isOfflineError = false
        
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
            } catch let error as MoviesRepositoryError {
                handleRepositoryError(error)
            } catch let error as MoviesDatasourceError {
                errorMessage = error.errorDescription
                isOfflineError = false
            } catch {
                errorMessage = "error.unexpected".localized(with: error.localizedDescription)
                isOfflineError = false
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
        errorMessage = nil
        isOfflineError = false
    }
    
    // MARK: - Error Handling
    
    @MainActor
    private func handleRepositoryError(_ error: MoviesRepositoryError) {
        switch error {
        case .noInternetConnection:
            errorMessage = "offline.no_cache.message".localized()
            isOfflineError = true
            movies = []
        case .cacheNotAvailable:
            errorMessage = "error.cache_unavailable".localized()
            isOfflineError = false
            movies = []
        }
    }
}
