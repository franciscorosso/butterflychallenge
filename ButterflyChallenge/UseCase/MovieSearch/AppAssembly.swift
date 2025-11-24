//
//  AppAssembly.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Swinject

/// Main assembly for registering all app dependencies with Swinject
final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        // MARK: - Configuration
        
        container.register(String.self, name: "APIAccessToken") { _ in
            "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYTY0NmJiNGRlODQwMzU1YzlhZTdiM2IwYWIxMjgyYiIsIm5iZiI6MTc2MzkzNzYzMC4wMDQ5OTk5LCJzdWIiOiI2OTIzOGQ1ZGI2OGQ0YzYzNmUwYmE5MWMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.04Gf9nPLFOLEBZaFkrzY3aeeo-NHiJJWeFTcLfsB6hw"
        }
        
        // MARK: - Datasource Layer
        
        container.register(MoviesDatasource.self) { resolver in
            let accessToken = resolver.resolve(String.self, name: "APIAccessToken")!
            return MoviesRemoteDatasourceImpl(accessToken: accessToken)
        }.inObjectScope(.container) // Singleton
        
        // MARK: - Repository Layer
        
        container.register(MoviesRepository.self) { resolver in
            let datasource = resolver.resolve(MoviesDatasource.self)!
            return MoviesRepositoryImpl(remoteDatasource: datasource)
        }.inObjectScope(.container) // Singleton
        
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
        
        // Factory for MovieDetailViewModel since it requires a parameter
        container.register(MovieDetailViewModel.self) { (resolver, movieId: Int) in
            let useCase = resolver.resolve(GetMovieDetailUseCase.self)!
            return MovieDetailViewModel(movieId: movieId, getMovieDetailUseCase: useCase)
        }
    }
}
