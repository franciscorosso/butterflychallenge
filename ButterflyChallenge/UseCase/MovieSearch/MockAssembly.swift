//
//  MockAssembly.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Swinject

/// Mock assembly for testing purposes
/// Use this to register mock dependencies for unit tests
final class MockAssembly: Assembly {
    
    func assemble(container: Container) {
        // MARK: - Mock Datasource Layer
        
        container.register(MoviesDatasource.self) { _ in
            MockMoviesDatasource()
        }.inObjectScope(.container)
        
        // MARK: - Repository Layer
        
        container.register(MoviesRepository.self) { resolver in
            let datasource = resolver.resolve(MoviesDatasource.self)!
            return MoviesRepositoryImpl(remoteDatasource: datasource)
        }.inObjectScope(.container)
        
        // MARK: - Use Cases
        
        container.register(SearchMoviesUseCase.self) { resolver in
            let repository = resolver.resolve(MoviesRepository.self)!
            return SearchMoviesUseCaseImpl(repository: repository)
        }
        
        container.register(GetMovieDetailUseCase.self) { resolver in
            let repository = resolver.resolve(MoviesRepository.self)!
            return GetMovieDetailUseCaseImpl(repository: repository)
        }
        
        // MARK: - View Models
        
        container.register(MovieSearchViewModel.self) { resolver in
            let useCase = resolver.resolve(SearchMoviesUseCase.self)!
            return MovieSearchViewModel(searchMoviesUseCase: useCase)
        }
        
        container.register(MovieDetailViewModel.self) { (resolver, movieId: Int) in
            let useCase = resolver.resolve(GetMovieDetailUseCase.self)!
            return MovieDetailViewModel(movieId: movieId, getMovieDetailUseCase: useCase)
        }
    }
}

// MARK: - Mock Implementations

final class MockMoviesDatasource: MoviesDatasource {
    var shouldFail = false
    var mockSearchResponse: MovieSearchResponse?
    var mockMovieDetail: MovieDetail?
    
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponse {
        if shouldFail {
            throw MoviesDatasourceError.networkError(NSError(domain: "Mock", code: -1))
        }
        
        return mockSearchResponse ?? MovieSearchResponse(
            page: 1,
            results: [mockMovie()],
            totalPages: 1,
            totalResults: 1
        )
    }
    
    func getMovieDetail(movieId: Int) async throws -> MovieDetail {
        if shouldFail {
            throw MoviesDatasourceError.networkError(NSError(domain: "Mock", code: -1))
        }
        
        return mockMovieDetail ?? mockMovieDetailData()
    }
    
    // MARK: - Mock Data Helpers
    
    private func mockMovie() -> Movie {
        Movie(
            id: 550,
            title: "Fight Club",
            overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.433,
            voteCount: 26279,
            popularity: 73.433,
            adult: false,
            video: false,
            originalLanguage: "en",
            originalTitle: "Fight Club",
            genreIds: [18, 53, 35]
        )
    }
    
    private func mockMovieDetailData() -> MovieDetail {
        MovieDetail(
            id: 550,
            title: "Fight Club",
            overview: "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.433,
            voteCount: 26279,
            popularity: 73.433,
            runtime: 139,
            budget: 63000000,
            revenue: 100853753,
            status: "Released",
            tagline: "Mischief. Mayhem. Soap.",
            adult: false,
            video: false,
            originalLanguage: "en",
            originalTitle: "Fight Club",
            genres: [
                Genre(id: 18, name: "Drama"),
                Genre(id: 53, name: "Thriller"),
                Genre(id: 35, name: "Comedy")
            ],
            productionCompanies: [
                ProductionCompany(id: 508, name: "Regency Enterprises", logoPath: nil, originCountry: "US")
            ],
            homepage: "http://www.foxmovies.com/movies/fight-club"
        )
    }
}
