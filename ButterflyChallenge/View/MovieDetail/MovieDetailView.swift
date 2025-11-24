//
//  MovieDetailView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct MovieDetailView: View {
    @State private var viewModel: MovieDetailViewModel
    
    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let errorMessage = viewModel.errorMessage {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Retry") {
                            Task {
                                await viewModel.retry()
                            }
                        }
                    }
                }
            } else if let movie = viewModel.movieDetail {
                movieDetailContent(movie: movie)
            }
        }
        .task {
            await viewModel.loadMovieDetail()
        }
    }
    
    @ViewBuilder
    private func movieDetailContent(movie: MovieDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Backdrop Image
                backdropHeader(movie: movie)
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Basic Info
                    titleSection(movie: movie)
                    
                    // Tagline
                    if let tagline = movie.tagline, !tagline.isEmpty {
                        Text(tagline)
                            .font(.subheadline)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                    
                    // Overview
                    if !movie.overview.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Overview")
                                .font(.headline)
                            Text(movie.overview)
                                .font(.body)
                        }
                    }
                    
                    // Stats
                    statsSection(movie: movie)
                    
                    // Genres
                    if !movie.genres.isEmpty {
                        genresSection(movie: movie)
                    }
                    
                    // Production Companies
                    if !movie.productionCompanies.isEmpty {
                        productionCompaniesSection(movie: movie)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func backdropHeader(movie: MovieDetail) -> some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: movie.backdropURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    }
            }
            .frame(height: 250)
            .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.7)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Poster thumbnail
            HStack(alignment: .bottom, spacing: 12) {
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 8)
                
                Spacer()
            }
            .padding()
        }
        .frame(height: 250)
    }
    
    @ViewBuilder
    private func titleSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 12) {
                if let year = movie.releaseYear {
                    Label(year, systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if let runtime = movie.formattedRuntime {
                    Label(runtime, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", movie.voteAverage))
                        .fontWeight(.semibold)
                    Text("(\(movie.voteCount))")
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    private func statsSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                if let budget = movie.formattedBudget {
                    statRow(title: "Budget", value: budget)
                }
                
                if let revenue = movie.formattedRevenue {
                    statRow(title: "Revenue", value: revenue)
                }
                
                statRow(title: "Status", value: movie.status)
                
                if let releaseDate = movie.releaseDate {
                    statRow(title: "Release Date", value: releaseDate)
                }
                
                statRow(title: "Original Language", value: movie.originalLanguage.uppercased())
            }
        }
    }
    
    @ViewBuilder
    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
    
    @ViewBuilder
    private func genresSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Genres")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(movie.genres) { genre in
                        Text(genre.name)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func productionCompaniesSection(movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Production Companies")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(movie.productionCompanies) { company in
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundStyle(.secondary)
                        Text(company.name)
                            .font(.subheadline)
                        Spacer()
                        Text(company.originCountry)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    let mockMovie = MovieDetail(
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
            ProductionCompany(id: 508, name: "Regency Enterprises", logoPath: nil, originCountry: "US"),
            ProductionCompany(id: 711, name: "Fox 2000 Pictures", logoPath: nil, originCountry: "US")
        ],
        homepage: "http://www.foxmovies.com/movies/fight-club"
    )
    
    let mockDatasource = MoviesRemoteDatasourceImpl(accessToken: "mock_token")
    let mockRepository = MoviesRepositoryImpl(remoteDatasource: mockDatasource)
    let mockUseCase = GetMovieDetailUseCaseImpl(repository: mockRepository)
    let viewModel = MovieDetailViewModel(movieId: 550, getMovieDetailUseCase: mockUseCase)
    viewModel.movieDetail = mockMovie
    
    return NavigationStack {
        MovieDetailView(viewModel: viewModel)
    }
}
