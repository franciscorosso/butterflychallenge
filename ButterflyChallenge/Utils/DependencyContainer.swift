//
//  DependencyContainer.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import Foundation
import Swinject

/// Dependency container for managing app dependencies using Swinject
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    // MARK: - Properties
    
    private let container: Container
    private let assembler: Assembler
    
    // MARK: - Initialization
    
    private init() {
        self.container = Container()
        self.assembler = Assembler([AppAssembly()], container: container)
    }
    
    // MARK: - Resolvers
    
    var resolver: Resolver {
        return assembler.resolver
    }
    
    // MARK: - View Model Factory Methods
    
    func makeMoviesViewModel() -> MovieSearchViewModel {
        guard let viewModel = resolver.resolve(MovieSearchViewModel.self) else {
            fatalError("SearchMoviesViewModel not registered in container")
        }
        return viewModel
    }
    
    func makeFavoritesViewModel() -> FavoritesViewModel {
        guard let viewModel = resolver.resolve(FavoritesViewModel.self) else {
            fatalError("FavoritesViewModel not registered in container")
        }
        return viewModel
    }
    
    func makeMovieDetailViewModel(movieId: Int) -> MovieDetailViewModel {
        guard let viewModel = resolver.resolve(MovieDetailViewModel.self, argument: movieId) else {
            fatalError("MovieDetailViewModel not registered in container")
        }
        return viewModel
    }
    
    // MARK: - Testing Support
    
    /// Create a container with custom assemblies (useful for testing)
    static func makeTestContainer(assemblies: [Assembly]) -> Resolver {
        let container = Container()
        let assembler = Assembler(assemblies, container: container)
        return assembler.resolver
    }
}
