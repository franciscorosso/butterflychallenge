//
//  MoviesView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct MoviesView: View {
    @State private var viewModel: MoviesViewModel
    
    init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Error",
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.movies.isEmpty && !viewModel.searchQuery.isEmpty {
                    ContentUnavailableView.search
                } else if viewModel.movies.isEmpty {
                    ContentUnavailableView(
                        "Search Movies",
                        systemImage: "film",
                        description: Text("Enter a movie title to start searching")
                    )
                } else {
                    moviesList
                }
            }
            .navigationTitle("Movie Search")
            .searchable(
                text: $viewModel.searchQuery,
                prompt: "Search for movies..."
            )
            .onChange(of: viewModel.searchQuery) {
                Task {
                    await viewModel.searchMovies()
                }
            }
            .onChange(of: viewModel.searchQuery) { oldValue, newValue in
                if newValue.isEmpty {
                    viewModel.clearSearch()
                }
            }
        }
    }
    
    private var moviesList: some View {
        List {
            Section {
                ForEach(viewModel.movies) { movie in
                    MovieRowView(movie: movie)
                }
            } header: {
                if viewModel.totalResults > 0 {
                    Text("Found \(viewModel.totalResults) results")
                }
            }
        }
    }
}

#Preview {
    let mockMovie = Movie(
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
    
    // Create mock dependencies
    let mockDatasource = MoviesRemoteDatasourceImpl(accessToken: "mock_token")
    let mockRepository = MoviesRepositoryImpl(remoteDatasource: mockDatasource)
    let mockUseCase = SearchMoviesUseCaseImpl(repository: mockRepository)
    let viewModel = MoviesViewModel(searchMoviesUseCase: mockUseCase)
    
    // Set some test data
    viewModel.movies = [mockMovie]
    viewModel.totalResults = 1
    
    return MoviesView(viewModel: viewModel)
}
