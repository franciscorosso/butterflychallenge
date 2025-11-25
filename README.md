# ButterflyChallenge 🎬

An iOS movie discovery app built with SwiftUI that allows users to search for movies, view detailed information, and manage their favorite films. The app demonstrates clean architecture principles, offline-first functionality, and comprehensive testing.

## Features

### 🔍 Movie Search
- Real-time movie search using The Movie Database (TMDB) API
- Pagination support for browsing large result sets
- Offline-first architecture with intelligent caching
- Beautiful grid layout with movie posters and ratings

### 📱 Movie Details
- Comprehensive movie information including:
  - Overview and tagline
  - Release date and status
  - Production companies and genres
  - High-quality poster and backdrop images
- Toggle favorites directly from the detail view

### ⭐ Favorites
- Save movies to favorites for quick access
- Persistent storage using SwiftData
- View all favorites in a dedicated tab
- Remove favorites with a single tap

### 🌐 Offline Support
- Works seamlessly without internet connection when data is cached
- Background cache updates when network becomes available
- Network status monitoring with visual feedback
- User-friendly offline error messages

## Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │   SwiftUI   │  │  ViewModels  │  │  @Observable  │  │
│  │    Views    │──│   (MVVM)     │──│     State     │  │
│  └─────────────┘  └──────────────┘  └───────────────┘  │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                     Domain Layer                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              Use Cases (Interactors)             │   │
│  │  • GetMovieDetailUseCase                         │   │
│  │  • SearchMoviesUseCase                           │   │
│  │  • ToggleFavoriteUseCase                         │   │
│  └─────────────────────────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────────────┐  ┌────────────────────────────┐  │
│  │   Repositories   │  │      Data Sources          │  │
│  │  • Movies        │──│  • Remote (API)            │  │
│  │  • Favorites     │  │  • Local (Cache/SwiftData) │  │
│  └──────────────────┘  └────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Architectural Components

#### **Presentation Layer**
- **SwiftUI Views**: Declarative UI components
- **ViewModels**: Business logic and state management using `@Observable` macro
- **Navigation**: Modern navigation patterns with SwiftUI

#### **Domain Layer**
- **Use Cases**: Encapsulate business logic and orchestrate data flow
- **Models**: Domain entities (`Movie`, `MovieDetail`, `FavoriteMovie`)
- **Protocols**: Define contracts between layers

#### **Data Layer**
- **Repositories**: Abstract data sources and provide unified interface
- **Remote Data Source**: API communication with TMDB
- **Local Data Source**: Caching with SwiftData and UserDefaults
- **Network Monitor**: Real-time connectivity status

## Project Structure

```
ButterflyChallenge/
├── Presentation/
│   ├── Views/
│   │   ├── MovieSearchView.swift
│   │   ├── MovieDetailView.swift
│   │   ├── FavoritesView.swift
│   │   ├── Components/
│   │   │   ├── MovieRow.swift
│   │   │   ├── NetworkStatusBanner.swift
│   │   │   └── OfflineStateView.swift
│   │   └── ...
│   └── ViewModels/
│       ├── MovieSearchViewModel.swift
│       ├── MovieDetailViewModel.swift
│       └── FavoritesViewModel.swift
│
├── Domain/
│   ├── UseCases/
│   │   ├── GetMovieDetailUseCase.swift
│   │   ├── SearchMoviesUseCase.swift
│   │   ├── ToggleFavoriteUseCase.swift
│   │   └── GetFavoritesUseCase.swift
│   └── Models/
│       ├── Movie.swift
│       ├── MovieDetail.swift
│       └── FavoriteMovie.swift
│
├── Data/
│   ├── Repositories/
│   │   ├── MoviesRepository.swift
│   │   └── FavoritesRepository.swift
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   └── MoviesRemoteDatasource.swift
│   │   └── Local/
│   │       ├── MoviesLocalDataSource.swift
│   │       └── FavoritesDataSource.swift
│   └── Network/
│       ├── NetworkMonitor.swift
│       ├── API.swift
│       └── APIError.swift
│
├── Core/
│   ├── DependencyInjection/
│   │   ├── DependencyContainer.swift
│   │   └── AppAssembly.swift
│   ├── Extensions/
│   │   └── String+Localization.swift
│   └── Utilities/
│       └── SecretsManager.swift
│
└── Tests/
    └── MovieDetailViewModelTests.swift
```

## Technologies & Frameworks

- **SwiftUI**: Modern declarative UI framework
- **Observation Framework**: State management with `@Observable` macro
- **Swift Concurrency**: Async/await for asynchronous operations
- **SwiftData**: Modern persistence framework for favorites and caching
- **Swinject**: Dependency injection container
- **Network Framework**: Real-time network connectivity monitoring
- **Swift Testing**: Modern testing framework with macros
- **ViewInspector**: Library for unit testing SwiftUI views. It allows for traversing a view hierarchy at runtime providing direct access to the underlying View structs.

## Technical Highlights

### Offline-First Architecture
The app implements a sophisticated offline-first strategy:
1. **Check cache first**: Always attempt to serve from local cache
2. **Background updates**: Silently update cache when online
3. **Graceful degradation**: Clear error messages when offline without cache
4. **Smart caching**: Store both search results and movie details

### Dependency Injection
Using Swinject for clean dependency management:
- Protocol-oriented design for testability
- Singleton pattern for shared resources
- Factory methods for view models
- Easy to mock for testing

### State Management
Modern state management with `@Observable`:
- No need for `@Published` or `ObservableObject`
- Simplified syntax with automatic observation
- Better performance with fine-grained updates

### Error Handling
Comprehensive error handling:
- Custom error types for different layers
- Repository errors (network, cache)
- API errors (HTTP status codes)
- User-friendly error messages with localization

### Challenges faced
- ViewInspector doesn’t fully integrate with the modern Swift Testing framework, so using XCTest-based assertions was the most reliable approach.

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- TMDB API Key

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ButterflyChallenge.git
   cd ButterflyChallenge
   ```

2. **Install dependencies**
   - Dependencies are managed via Swift Package Manager
   - Xcode will automatically resolve packages on first build

3. **Configure API Key**
   
   The app uses TMDB API. You need to add your API key:
   
   Option 1: Using Secrets file (recommended)
   - Go to`Secrets.plist` file in the project root
   - Add your API key:
     ```xml
     <?xml version="1.0" encoding="UTF-8"?>
     <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
     <plist version="1.0">
     <dict>
         <key>APIAccessToken</key>
         <string>ADD_TOKEN</string>
     </dict>
     </plist>
     ```

4. **Build and Run**
   - Open `ButterflyChallenge.xcodeproj` in Xcode
   - Select a simulator or device
   - Press `Cmd + R` to build and run

### Getting a TMDB API Key

1. Create a free account at [themoviedb.org](https://www.themoviedb.org/)
2. Navigate to Settings → API
3. Request an API key (choose "Developer" for personal use)
4. Copy your API key and add it to the project as described above

## Testing

The project includes comprehensive unit tests using the Swift Testing framework.

### Running Tests
```bash
# In Xcode
⌘ + U

# Or from command line
xcodebuild test -scheme ButterflyChallenge -destination 'platform=iOS Simulator,name=iPhone 15'
```

## API Integration

### TMDB API v3
The app uses The Movie Database (TMDB) API v3:

**Base URL**: `https://api.themoviedb.org/3`

**Endpoints Used**:
- `GET /search/movie` - Search for movies
- `GET /movie/{movie_id}` - Get movie details

**Authentication**:
- API Key authentication via query parameter
- Secure key storage using SecretsManager

## Performance Optimizations

1. **Lazy Loading**: Images loaded on-demand with AsyncImage
2. **Pagination**: Load search results in pages to reduce memory usage
3. **Caching**: Aggressive caching strategy to minimize network calls
4. **Background Updates**: Non-blocking cache updates
5. **SwiftData**: Efficient persistence with modern data framework
6. **Debounce**: Debouncing when calling the endpoint for Search Movie.

## Images
<img width="435" height="847" alt="Captura de pantalla 2025-11-24 a la(s) 22 23 33" src="https://github.com/user-attachments/assets/d4423e8b-49ba-42c7-b8aa-0904ae3c033d" />
<img width="435" height="847" alt="Captura de pantalla 2025-11-24 a la(s) 22 23 29" src="https://github.com/user-attachments/assets/ab12a0dd-496f-4774-a66c-2bd84fbda98f" />
<img width="435" height="847" alt="Captura de pantalla 2025-11-24 a la(s) 22 23 24" src="https://github.com/user-attachments/assets/32aad580-7cc0-4336-af85-8f32b2e6aa64" />
<img width="435" height="847" alt="Captura de pantalla 2025-11-24 a la(s) 22 23 18" src="https://github.com/user-attachments/assets/9346f490-fa67-41a6-b291-542464bdd58b" />
<img width="621" height="1344" alt="Captura de pantalla 2025-11-24 a la(s) 22 27 21" src="https://github.com/user-attachments/assets/46096513-0de2-4828-9f10-9acf0c0b324c" />

## License

This project is created as a coding challenge.

## Acknowledgments

- [The Movie Database (TMDB)](https://www.themoviedb.org/) for the API.
- [Swinject](https://github.com/Swinject/Swinject) for dependency injection.
- [ViewInspector](https://github.com/nalexn/ViewInspector) for UI tests.
- Apple's Swift and SwiftUI teams for amazing frameworks.

## Contact

Francisco Rosso
- GitHub: [@franciscorosso](https://github.com/franciscorosso)

---
