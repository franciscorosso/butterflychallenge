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
    
    var movies: [Movie] = []
    var searchQuery: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var currentPage: Int = 0
    var totalPages: Int = 0
    var totalResults: Int = 0
    
    init(searchMoviesUseCase: SearchMoviesUseCase) {
        self.searchMoviesUseCase = searchMoviesUseCase
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
                let response = try await searchMoviesUseCase.execute(query: searchQuery)

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
        searchQuery = ""
        movies = []
        errorMessage = nil
        currentPage = 0
        totalPages = 0
        totalResults = 0
    }
}
