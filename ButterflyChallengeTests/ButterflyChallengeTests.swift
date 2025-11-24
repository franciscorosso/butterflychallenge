//
//  ButterflyChallengeTests.swift
//  ButterflyChallengeTests
//
//  Created by Francisco Rosso on 24/11/2025.
//

import XCTest
import Swinject
@testable import ButterflyChallenge

final class ButterflyChallengeTests: XCTestCase {
    
    var resolver: Resolver!
    var mockDatasource: MockMoviesDatasource!

    override func setUpWithError() throws {
        // Setup Swinject with mock dependencies
        resolver = DependencyContainer.makeTestContainer(assemblies: [MockAssembly()])
        
        // Get reference to mock datasource for controlling test behavior
        mockDatasource = resolver.resolve(MoviesDatasource.self) as? MockMoviesDatasource
    }

    override func tearDownWithError() throws {
        resolver = nil
        mockDatasource = nil
    }

    // MARK: - SearchMoviesViewModel Tests
    
    func testSearchMoviesSuccess() async throws {
        // Given
        let viewModel = resolver.resolve(SearchMoviesViewModel.self)!
        viewModel.searchQuery = "Fight Club"
        
        // When
        await viewModel.searchMovies()
        
        // Then
        XCTAssertFalse(viewModel.movies.isEmpty, "Movies should not be empty")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
        XCTAssertEqual(viewModel.movies.first?.title, "Fight Club")
    }
    
    func testSearchMoviesFailure() async throws {
        // Given
        let viewModel = resolver.resolve(SearchMoviesViewModel.self)!
        viewModel.searchQuery = "Test"
        mockDatasource.shouldFail = true
        
        // When
        await viewModel.searchMovies()
        
        // Then
        XCTAssertTrue(viewModel.movies.isEmpty, "Movies should be empty on error")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should not be nil")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
    }
    
    func testClearSearch() {
        // Given
        let viewModel = resolver.resolve(SearchMoviesViewModel.self)!
        viewModel.searchQuery = "Test"
        viewModel.movies = [Movie(
            id: 1,
            title: "Test Movie",
            overview: "Test",
            posterPath: nil,
            backdropPath: nil,
            releaseDate: nil,
            voteAverage: 0,
            voteCount: 0,
            popularity: 0,
            adult: false,
            video: false,
            originalLanguage: "en",
            originalTitle: "Test",
            genreIds: []
        )]
        
        // When
        viewModel.clearSearch()
        
        // Then
        XCTAssertTrue(viewModel.movies.isEmpty, "Movies should be cleared")
        XCTAssertEqual(viewModel.searchQuery, "", "Search query should be empty")
        XCTAssertEqual(viewModel.currentPage, 0, "Current page should be reset")
    }
    
    // MARK: - MovieDetailViewModel Tests
    
    func testLoadMovieDetailSuccess() async throws {
        // Given
        let viewModel = resolver.resolve(MovieDetailViewModel.self, argument: 550)!
        
        // When
        await viewModel.loadMovieDetail()
        
        // Then
        XCTAssertNotNil(viewModel.movieDetail, "Movie detail should not be nil")
        XCTAssertNil(viewModel.errorMessage, "Error message should be nil")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
        XCTAssertEqual(viewModel.movieDetail?.title, "Fight Club")
    }
    
    func testLoadMovieDetailFailure() async throws {
        // Given
        let viewModel = resolver.resolve(MovieDetailViewModel.self, argument: 550)!
        mockDatasource.shouldFail = true
        
        // When
        await viewModel.loadMovieDetail()
        
        // Then
        XCTAssertNil(viewModel.movieDetail, "Movie detail should be nil on error")
        XCTAssertNotNil(viewModel.errorMessage, "Error message should not be nil")
        XCTAssertFalse(viewModel.isLoading, "Loading should be false")
    }
    
    // MARK: - Use Case Tests
    
    func testSearchMoviesUseCaseWithEmptyQuery() async throws {
        // Given
        let useCase = resolver.resolve(SearchMoviesUseCase.self)!
        
        // When/Then
        do {
            _ = try await useCase.execute(query: "   ", page: 1)
            XCTFail("Should throw an error for empty query")
        } catch {
            XCTAssertTrue(error is MoviesDatasourceError)
        }
    }
    
    func testGetMovieDetailUseCase() async throws {
        // Given
        let useCase = resolver.resolve(GetMovieDetailUseCase.self)!
        
        // When
        let detail = try await useCase.execute(movieId: 550)
        
        // Then
        XCTAssertEqual(detail.id, 550)
        XCTAssertEqual(detail.title, "Fight Club")
    }
}

