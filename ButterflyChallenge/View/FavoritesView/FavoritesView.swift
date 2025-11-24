//
//  FavoritesView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct FavoritesView: View {
    @State private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("general.loading".localized())
                } else if viewModel.favorites.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("favorites.title".localized())
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "favorites.empty.title".localized(),
            systemImage: "heart.slash",
            description: Text("favorites.empty.description".localized())
        )
    }
    
    private var favoritesList: some View {
        List {
            Section {
                ForEach(viewModel.favorites) { movie in
                    NavigationLink(value: movie.id) {
                        FavoriteMovieRow(movie: movie)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.removeFavorite(movie)
                            }
                        } label: {
                            Label("favorites.remove".localized(), systemImage: "heart.slash.fill")
                        }
                    }
                }
            } header: {
                if !viewModel.favorites.isEmpty {
                    Text("favorites.count".localized(with: viewModel.favorites.count))
                }
            }
        }
        .navigationDestination(for: Int.self) { movieId in
            let detailViewModel = DependencyContainer.shared.makeMovieDetailViewModel(movieId: movieId)
            MovieDetailView(viewModel: detailViewModel)
        }
    }
}

// MARK: - Favorite Movie Row

struct FavoriteMovieRow: View {
    let movie: FavoriteMovie
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: movie.posterURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.gray)
                    }
            }
            .frame(width: 60, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
                    Text(releaseDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("(\(movie.voteCount))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .padding(.top, 2)
                }
                
                // Added date
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.pink)
                    Text("favorites.added".localized(with: movie.addedDate.formatted(date: .abbreviated, time: .omitted)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}
