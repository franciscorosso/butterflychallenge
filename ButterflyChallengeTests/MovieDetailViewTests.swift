//
//  MovieDetailViewTests.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Testing
import XCTest
import SwiftUI
import ViewInspector
@testable import ButterflyChallenge

@Suite("MovieDetailView UI Tests")
@MainActor
struct MovieDetailViewTests {

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
            genres: [Genre(id: 1, name: "Action"), Genre(id: 2, name: "Drama")],
            productionCompanies: [
                ProductionCompany(id: 1, name: "Test Studios", logoPath: nil, originCountry: "US"),
                ProductionCompany(id: 2, name: "Another Studio", logoPath: nil, originCountry: "UK")
            ],
            homepage: "https://test.com"
        )
    }

    private func makeViewModel(
        movieDetail: MovieDetail? = nil,
        isLoading: Bool = false,
        errorMessage: String? = nil,
        isOfflineError: Bool = false,
        isFavorite: Bool = false
    ) -> MovieDetailViewModel {
        let mockUseCase = MockGetMovieDetailUseCase()
        let mockToggleUseCase = MockToggleFavoriteUseCase()

        let viewModel = MovieDetailViewModel(
            movieId: 123,
            getMovieDetailUseCase: mockUseCase,
            toggleFavoriteUseCase: mockToggleUseCase
        )

        viewModel.movieDetail = movieDetail
        viewModel.isLoading = isLoading
        viewModel.errorMessage = errorMessage
        viewModel.isOfflineError = isOfflineError
        viewModel.isFavorite = isFavorite

        return viewModel
    }

    @Test("View displays offline error state correctly")
    func testOfflineErrorState() throws {
        let viewModel = makeViewModel(
            errorMessage: "No internet connection",
            isOfflineError: true
        )
        let view = MovieDetailView(viewModel: viewModel)

        let offlineView = try? view.inspect().find(OfflineStateView.self)
        XCTAssertNotNil(offlineView)
    }

    @Test("View displays movie title correctly")
    func testMovieTitleDisplay() throws {
        let movie = makeMockMovieDetail()
        let viewModel = makeViewModel(movieDetail: movie)
        let view = MovieDetailView(viewModel: viewModel)

        let titleText = try? view.inspect().find(text: "Test Movie")
        XCTAssertEqual(try titleText?.string(), "Test Movie")
    }

    @Test("View contains ScrollView when movie detail is loaded")
    func testScrollViewPresent() throws {
        let movie = makeMockMovieDetail()
        let viewModel = makeViewModel(movieDetail: movie)
        let view = MovieDetailView(viewModel: viewModel)

        let scrollView = try? view.inspect().find(ScrollView<AnyView>.self)
        XCTAssertNotNil(scrollView)
    }

    @Test("View contains AsyncImage for poster and backdrop thumbnail")
    func testPosterImagePresent() throws {
        let movie = makeMockMovieDetail()
        let viewModel = makeViewModel(movieDetail: movie)
        let view = MovieDetailView(viewModel: viewModel)
        
        let asyncImages = try view.inspect().findAll(AsyncImage<AnyView>.self)
        XCTAssertTrue(asyncImages.count == 2)
    }


    @Test("View handles movie without production companies")
    func testMovieWithoutProductionCompanies() throws {
        let movieWithoutCompanies = MovieDetail(
            id: 123,
            title: "Test Movie",
            overview: "An overview",
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
            productionCompanies: [],
            homepage: "https://test.com"
        )
        
        let viewModel = makeViewModel(movieDetail: movieWithoutCompanies)
        let view = MovieDetailView(viewModel: viewModel)
        
        // Should still display title
        let titleText = try? view.inspect().find(text: "Test Movie")
        XCTAssertNotNil(try? titleText?.string())
    }
}
