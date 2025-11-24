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
            VStack {
                if viewModel.isLoading {
                    ProgressView("movie_search.searching".localized())
                        .padding()
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
                    NavigationLink(value: movie.id) {
                        MovieRowView(movie: movie)
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreMoviesIfNeeded(movie)
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
                                systemImage: viewModel.isFavorite(movieId: movie.id) ? "heart.fill" : "heart.slash.fill"
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
                if viewModel.totalResults > 0 {
                    Text("movie_search.results_count".localized(with: viewModel.totalResults))
                }
            } footer: {
                if viewModel.currentPage == viewModel.totalPages && viewModel.totalPages > 0 {
                    Text("movie_search.end_of_results".localized())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
        }
        .navigationDestination(for: Int.self) { movieId in
            let detailViewModel = DependencyContainer.shared.makeMovieDetailViewModel(movieId: movieId)
            MovieDetailView(viewModel: detailViewModel)
        }
    }
}
