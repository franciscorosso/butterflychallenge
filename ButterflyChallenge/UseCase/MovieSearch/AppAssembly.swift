//
//  AppAssembly.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Swinject
import SwiftData

/// Main assembly for registering all app dependencies with Swinject
final class AppAssembly: Assembly {
    
    func assemble(container: Container) {
        // MARK: - Configuration
        
        container.register(String.self, name: "APIAccessToken") { _ in
            "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYTY0NmJiNGRlODQwMzU1YzlhZTdiM2IwYWIxMjgyYiIsIm5iZiI6MTc2MzkzNzYzMC4wMDQ5OTk5LCJzdWIiOiI2OTIzOGQ1ZGI2OGQ0YzYzNmUwYmE5MWMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.04Gf9nPLFOLEBZaFkrzY3aeeo-NHiJJWeFTcLfsB6hw"
        }
        
        // MARK: - SwiftData
        
        container.register(ModelContainer.self) { _ in
            let schema = Schema([
                CachedMovieEntity.self,
                CachedMovieDetailEntity.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }.inObjectScope(.container)
        
        // MARK: - Network & Monitoring
        
        container.register(NetworkMonitor.self) { _ in
            return NetworkMonitorImpl()
        }.inObjectScope(.container)
        
        // MARK: - Datasource Layer
        
        container.register(MoviesRemoteDatasource.self) { resolver in
            let accessToken = resolver.resolve(String.self, name: "APIAccessToken")!
            return MoviesRemoteDatasourceImpl(accessToken: accessToken)
        }.inObjectScope(.container)
        
        container.register(MoviesLocalDataSource.self) { resolver in
            let modelContainer = resolver.resolve(ModelContainer.self)!
            return MoviesLocalDataSourceSwiftDataImpl(modelContainer: modelContainer)
        }.inObjectScope(.container)
        
        container.register(FavoritesDataSource.self) { _ in
            return FavoritesDataSourceImpl()
        }.inObjectScope(.container)
        
        // MARK: - Repository Layer
        
        container.register(MoviesRepository.self) { resolver in
            let remoteDataSource = resolver.resolve(MoviesRemoteDatasource.self)!
            let localDataSource = resolver.resolve(MoviesLocalDataSource.self)!
            let networkMonitor = resolver.resolve(NetworkMonitor.self)!
            return MoviesRepositoryImpl(
                remoteDataSource: remoteDataSource,
                localDataSource: localDataSource,
                networkMonitor: networkMonitor
            )
        }.inObjectScope(.container)

        container.register(FavoritesRepository.self) { resolver in
            let datasource = resolver.resolve(FavoritesDataSource.self)!
            return FavoritesRepositoryImpl(dataSource: datasource)
        }.inObjectScope(.container)

        // MARK: - Use Cases
        
        container.register(MovieSearchUseCase.self) { resolver in
            let repository = resolver.resolve(MoviesRepository.self)!
            return MovieSearchUseCaseImpl(repository: repository)
        }
        
        container.register(GetMovieDetailUseCase.self) { resolver in
            let repository = resolver.resolve(MoviesRepository.self)!
            return GetMovieDetailUseCaseImpl(repository: repository)
        }
        
        container.register(GetFavoritesUseCase.self) { resolver in
            let repository = resolver.resolve(FavoritesRepository.self)!
            return GetFavoritesUseCaseImpl(repository: repository)
        }

        container.register(ToggleFavoriteUseCase.self) { resolver in
            let repository = resolver.resolve(FavoritesRepository.self)!
            return ToggleFavoriteUseCaseImpl(repository: repository)
        }
        
        // MARK: - View Models
        
        container.register(MovieSearchViewModel.self) { resolver in
            let searchUseCase = resolver.resolve(MovieSearchUseCase.self)!
            let toggleFavoriteUseCase = resolver.resolve(ToggleFavoriteUseCase.self)!
            let networkMonitor = resolver.resolve(NetworkMonitor.self)!
            return MovieSearchViewModel(
                searchMoviesUseCase: searchUseCase,
                toggleFavoriteUseCase: toggleFavoriteUseCase,
                networkMonitor: networkMonitor
            )
        }
        
        container.register(FavoritesViewModel.self) { resolver in
            let getFavoritesUseCase = resolver.resolve(GetFavoritesUseCase.self)!
            let toggleFavoriteUseCase = resolver.resolve(ToggleFavoriteUseCase.self)!
            return FavoritesViewModel(getFavoritesUseCase: getFavoritesUseCase, toggleFavoriteUseCase: toggleFavoriteUseCase)
        }

        container.register(MovieDetailViewModel.self) { (resolver, movieId: Int) in
            let getMovieDetailUseCase = resolver.resolve(GetMovieDetailUseCase.self)!
            let toggleFavoriteUseCase = resolver.resolve(ToggleFavoriteUseCase.self)!
            return MovieDetailViewModel(movieId: movieId, getMovieDetailUseCase: getMovieDetailUseCase, toggleFavoriteUseCase: toggleFavoriteUseCase)
        }
    }
}
