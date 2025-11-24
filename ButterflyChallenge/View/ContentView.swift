//
//  ContentView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct ContentView: View {
    let viewModel: MoviesViewModel
    
    init() {
        // Setup the complete dependency chain
        let datasource = MoviesRemoteDatasourceImpl(accessToken: Config.API.accessToken)
        let repository = MoviesRepositoryImpl(remoteDatasource: datasource)
        let useCase = SearchMoviesUseCaseImpl(repository: repository)
        self.viewModel = MoviesViewModel(searchMoviesUseCase: useCase)
    }
    
    var body: some View {
        MoviesView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
