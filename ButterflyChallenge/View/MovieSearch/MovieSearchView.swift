//
//  MovieSearchView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct MovieSearchView: View {
    @State private var viewModel: MovieSearchViewModel
    
    init(viewModel: MovieSearchViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NetworkStatusBanner(isConnected: viewModel.isConnected)
                    .animation(.spring(duration: 0.3), value: viewModel.isConnected)
                
                if viewModel.isLoading {
                    ProgressView("movie_search.searching".localized())
                        .padding()
                } else if viewModel.isOfflineError {
                    OfflineStateView(
                        message: viewModel.errorMessage,
                        retryAction: {
                            await viewModel.searchMovies()
                        }
                    )
                } else if let errorMessage = viewModel.errorMessage {
                    ContentUnavailableView(
                        "general.error".localized(),
                        systemImage: "exclamationmark.triangle",
                        description: Text(errorMessage)
                    )
                } else if viewModel.movies.isEmpty && !viewModel.searchQuery.isEmpty {
                    ContentUnavailableView.search
                } else if viewModel.movies.isEmpty {
                    ContentUnavailableView(
                        "movie_search.empty.title".localized(),
                        systemImage: "film",
                        description: Text("movie_search.empty.description".localized())
                    )
                } else {
                    moviesList
                }
            }
            .navigationTitle("movie_search.title".localized())
            .searchable(
                text: $viewModel.searchQuery,
                prompt: "movie_search.search_prompt".localized()
            )
            .onChange(of: viewModel.searchQuery) { oldValue, newValue in
                if newValue.isEmpty && viewModel.isConnected {
                    viewModel.clearSearch()
                } else {
                    Task {
                        await viewModel.searchMovies()
                    }
                }
            }
        }
    }
    
    private var moviesList: some View {
        List {
            Section {
                ForEach(viewModel.movies) { movie in
                    NavigationLink(value: movie.id) {
                        MovieRowView(movie: movie)
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreMovies(lastMovie: movie)
                                }
                            }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        let _ = viewModel.favoritesVersion
                        Button {
                            withAnimation {
                                viewModel.toggleFavorite(movie)
                            }
                        } label: {
                            Label(
                                viewModel.isFavorite(movieId: movie.id) ? "favorites.remove".localized() : "favorites.add".localized(),
                                systemImage: viewModel.isFavorite(movieId: movie.id) ? "heart.slash.fill" : "heart.fill"
                            )
                        }
                        .tint(viewModel.isFavorite(movieId: movie.id) ? .pink : .blue)
                    }
                }
                
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            } header: {
                Text("movie_search.results_count".localized(with: viewModel.totalResults))
            }
        }
        .navigationDestination(for: Int.self) { movieId in
            let detailViewModel = DependencyContainer.shared.makeMovieDetailViewModel(movieId: movieId)
            MovieDetailView(viewModel: detailViewModel)
        }
    }
}
