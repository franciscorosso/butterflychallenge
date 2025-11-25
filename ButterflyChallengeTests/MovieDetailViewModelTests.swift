//
//  MovieDetailViewModelTests.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Testing
import Foundation
@testable import ButterflyChallenge

@Suite("MovieDetailViewModel Tests")
@MainActor
struct MovieDetailViewModelTests {
    
    // MARK: - Test Data
    
    private func makeMockMovieDetail(id: Int = 123) -> MovieDetail {
        MovieDetail(
            id: id,
            title: "Test Movie",
            overview: "A test movie overview",
            posterPath: "/testPoster.jpg",
            backdropPath: "/testBackdrop.jpg",
            releaseDate: "2025-01-15",
            voteAverage: 8.5,
            voteCount: 1000,
            popularity: 500.0,
            runtime: 120,
            budget: 50000000,
            revenue: 150000000,
            status: "Released",
            tagline: "A test tagline",
            adult: false,
            video: false,
            originalLanguage: "en",
            originalTitle: "Test Movie Original",
            genres: [Genre(id: 1, name: "Action")],
            productionCompanies: [ProductionCompany(id: 1, name: "Test Studios", logoPath: nil, originCountry: "US")],
            homepage: "https://test.com"
        )
    }
    
    // MARK: - Init Tests

    @Test("ViewModel initializes with correct movie ID and initial state")
    func testInitialization() {
        let mockUseCase = MockGetMovieDetailUseCase()
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        #expect(viewModel.movieDetail == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isOfflineError == false)
    }
    
    @Test("ViewModel checks favorite status on initialization")
    func testInitializationChecksFavoriteStatus() {
        let mockUseCase = MockGetMovieDetailUseCase()
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        mockToggleUseCase.favoriteMovieIds = [123]
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        #expect(viewModel.isFavorite == true)
    }
    
    // MARK: - Load Movie Detail Tests
    
    @Test("Loading movie detail successfully updates state")
    func testLoadMovieDetailSuccess() async {
        let mockDetail = makeMockMovieDetail()
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(mockDetail)
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.movieDetail?.id == 123)
        #expect(viewModel.movieDetail?.title == "Test Movie")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isOfflineError == false)
        #expect(mockUseCase.executeCallCount == 1)
        #expect(mockUseCase.lastMovieId == 123)
    }
    
    @Test("Loading sets isLoading to true then false")
    func testLoadingStateTransitions() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        mockUseCase.delay = 0.1
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        Task {
            await viewModel.loadMovieDetail()
        }
        
        // Give it a moment to start loading
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        #expect(viewModel.isLoading == true)
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 150_000_000) // 0.15 seconds
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Loading updates favorite status after fetching details")
    func testLoadUpdatesFavoriteStatus() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        mockToggleUseCase.favoriteMovieIds = [123]
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.isFavorite == true)
    }
    
    @Test("Loading does not start if already loading")
    func testPreventsConcurrentLoading() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        mockUseCase.delay = 0.2
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        // Start first load
        let task1 = Task {
            await viewModel.loadMovieDetail()
        }
        
        // Try to start second load immediately
        try? await Task.sleep(nanoseconds: 10_000_000)
        let task2 = Task {
            await viewModel.loadMovieDetail()
        }
        
        await task1.value
        await task2.value
        
        // Should only have been called once
        #expect(mockUseCase.executeCallCount == 1)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("No internet connection error is handled correctly")
    func testNoInternetConnectionError() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .failure(MoviesRepositoryError.noInternetConnection)
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isOfflineError == true)
        #expect(viewModel.movieDetail == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Cache not available error is handled correctly")
    func testCacheNotAvailableError() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .failure(MoviesRepositoryError.cacheNotAvailable)
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isOfflineError == false)
        #expect(viewModel.movieDetail == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Generic error is handled correctly")
    func testGenericError() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .failure(TestError.genericError)
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isOfflineError == false)
        #expect(viewModel.movieDetail == nil)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Error state is cleared on successful retry")
    func testErrorClearedOnRetry() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .failure(MoviesRepositoryError.noInternetConnection)
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        // First load fails
        await viewModel.loadMovieDetail()
        #expect(viewModel.errorMessage != nil)
        
        // Now succeed
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        await viewModel.retry()
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isOfflineError == false)
        #expect(viewModel.movieDetail != nil)
    }
    
    // MARK: - Toggle Favorite Tests
    
    @Test("Toggle favorite adds movie when not favorite")
    func testToggleFavoriteAdds() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        // Load movie first
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.isFavorite == false)
        
        // Toggle to favorite
        viewModel.toggleFavorite()
        
        #expect(viewModel.isFavorite == true)
        #expect(mockToggleUseCase.executeCallCount == 1)
    }
    
    @Test("Toggle favorite removes movie when already favorite")
    func testToggleFavoriteRemoves() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        mockToggleUseCase.favoriteMovieIds = [123]
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        // Load movie first
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.isFavorite == true)
        
        // Toggle to remove
        viewModel.toggleFavorite()
        
        #expect(viewModel.isFavorite == false)
        #expect(mockToggleUseCase.executeCallCount == 1)
    }
    
    @Test("Toggle favorite does nothing when movie detail is nil")
    func testToggleFavoriteWithoutMovieDetail() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        // Don't load movie
        viewModel.toggleFavorite()
        
        #expect(mockToggleUseCase.executeCallCount == 0)
    }
    
    @Test("Multiple toggles alternate favorite state")
    func testMultipleToggles() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.loadMovieDetail()
        
        #expect(viewModel.isFavorite == false)
        
        viewModel.toggleFavorite()
        #expect(viewModel.isFavorite == true)
        
        viewModel.toggleFavorite()
        #expect(viewModel.isFavorite == false)
        
        viewModel.toggleFavorite()
        #expect(viewModel.isFavorite == true)
        
        #expect(mockToggleUseCase.executeCallCount == 3)
    }
    
    // MARK: - Retry Tests
    
    @Test("Retry calls loadMovieDetail")
    func testRetry() async {
        let mockUseCase = MockGetMovieDetailUseCase()
        mockUseCase.mockResult = .success(makeMockMovieDetail())
        let mockToggleUseCase = MockToggleFavoriteUseCase()
        
        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )
        
        await viewModel.retry()
        
        #expect(mockUseCase.executeCallCount == 1)
        #expect(viewModel.movieDetail != nil)
    }
}

// MARK: - Mock Use Cases

@MainActor
final class MockGetMovieDetailUseCase: GetMovieDetailUseCase {
    var mockResult: Result<MovieDetail, Error> = .failure(TestError.notSet)
    var executeCallCount = 0
    var lastMovieId: Int?
    var delay: TimeInterval = 0
    
    func execute(movieId: Int) async throws -> MovieDetail {
        executeCallCount += 1
        lastMovieId = movieId
        
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        switch mockResult {
        case .success(let detail):
            return detail
        case .failure(let error):
            throw error
        }
    }
}

@MainActor
final class MockToggleFavoriteUseCase: ToggleFavoriteUseCase {
    var favoriteMovieIds: Set<Int> = []
    var executeCallCount = 0
    var lastFavoriteMovie: FavoriteMovie?
    
    func execute(movie: FavoriteMovie) -> Bool {
        executeCallCount += 1
        lastFavoriteMovie = movie
        
        if favoriteMovieIds.contains(movie.id) {
            favoriteMovieIds.remove(movie.id)
            return false
        } else {
            favoriteMovieIds.insert(movie.id)
            return true
        }
    }
    
    func isFavorite(movieId: Int) -> Bool {
        return favoriteMovieIds.contains(movieId)
    }
}

// MARK: - Test Error

enum TestError: Error, LocalizedError {
    case notSet
    case genericError
    
    var errorDescription: String? {
        switch self {
        case .notSet:
            return "Mock result not set"
        case .genericError:
            return "A generic error occurred"
        }
    }
}
