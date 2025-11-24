# Swinject Dependency Injection Setup

## Overview

This project uses [Swinject](https://github.com/Swinject/Swinject) for dependency injection, providing a clean and testable architecture.

## Architecture

### Layers

1. **Datasource Layer** - API communication
2. **Repository Layer** - Data access abstraction
3. **Use Case Layer** - Business logic
4. **ViewModel Layer** - Presentation logic

### Dependency Flow

```
View → ViewModel → Use Case → Repository → Datasource
```

## Files

### AppAssembly.swift

The main assembly that registers all production dependencies:

- **Configuration**: API access token
- **Datasource**: `MoviesDatasource` (Singleton)
- **Repository**: `MoviesRepository` (Singleton)
- **Use Cases**: `SearchMoviesUseCase`, `GetMovieDetailUseCase`
- **ViewModels**: `SearchMoviesViewModel`, `MovieDetailViewModel`

### DependencyContainer.swift

The global dependency container that:

- Initializes Swinject `Container` and `Assembler`
- Provides factory methods for ViewModels
- Exposes a shared singleton instance
- Offers test container creation

### MockAssembly.swift

Assembly for testing that provides:

- Mock implementations of dependencies
- Controllable behavior for tests
- Same interface as production code

## Usage

### In Production Code

```swift
// Get the shared container
let container = DependencyContainer.shared

// Create ViewModels
let moviesViewModel = container.makeMoviesViewModel()
let detailViewModel = container.makeMovieDetailViewModel(movieId: 550)
```

### In Tests

```swift
import Swinject
@testable import ButterflyChallenge

class MyTests: XCTestCase {
    var resolver: Resolver!
    var mockDatasource: MockMoviesDatasource!
    
    override func setUp() {
        // Use mock assembly for testing
        resolver = DependencyContainer.makeTestContainer(assemblies: [MockAssembly()])
        mockDatasource = resolver.resolve(MoviesDatasource.self) as? MockMoviesDatasource
    }
    
    func testExample() async {
        // Control mock behavior
        mockDatasource.shouldFail = true
        
        // Resolve dependencies
        let viewModel = resolver.resolve(SearchMoviesViewModel.self)!
        
        // Test...
    }
}
```

### In SwiftUI Views

```swift
struct ContentView: View {
    let viewModel: SearchMoviesViewModel
    
    init() {
        self.viewModel = DependencyContainer.shared.makeMoviesViewModel()
    }
    
    var body: some View {
        MoviesView(viewModel: viewModel)
    }
}
```

## Benefits

### ✅ Testability

- Easy to swap real implementations with mocks
- No need for manual mock injection
- Consistent testing setup

### ✅ Maintainability

- Single source of truth for dependencies
- Clear separation of concerns
- Easy to add new dependencies

### ✅ Flexibility

- Different configurations for production/testing
- Singleton vs transient lifetimes
- Factory patterns for parameterized objects

### ✅ Type Safety

- Compile-time type checking
- Protocol-based dependencies
- Automatic dependency resolution

## Scopes

### Container Scope (Singleton)

Used for datasources and repositories that should be shared:

```swift
.inObjectScope(.container)
```

### Transient (Default)

New instance created every time:

```swift
// No scope modifier needed
container.register(SearchMoviesViewModel.self) { resolver in
    // Creates new instance each time
}
```

## Adding New Dependencies

### 1. Define Protocol

```swift
protocol MyNewUseCase {
    func execute() async throws -> Result
}
```

### 2. Implement

```swift
final class MyNewUseCaseImpl: MyNewUseCase {
    func execute() async throws -> Result {
        // Implementation
    }
}
```

### 3. Register in AppAssembly

```swift
container.register(MyNewUseCase.self) { resolver in
    let repository = resolver.resolve(MoviesRepository.self)!
    return MyNewUseCaseImpl(repository: repository)
}
```

### 4. Use in ViewModel

```swift
final class MyViewModel {
    private let myNewUseCase: MyNewUseCase
    
    init(myNewUseCase: MyNewUseCase) {
        self.myNewUseCase = myNewUseCase
    }
}

// Register ViewModel
container.register(MyViewModel.self) { resolver in
    let useCase = resolver.resolve(MyNewUseCase.self)!
    return MyViewModel(myNewUseCase: useCase)
}
```

## Best Practices

1. **Always use protocols** for dependencies
2. **Keep assemblies focused** - one assembly per feature if needed
3. **Use appropriate scopes** - singleton for expensive objects
4. **Test with mocks** - always create mock assemblies for testing
5. **Fail fast** - use `fatalError` for missing registrations in development

## Resources

- [Swinject Documentation](https://github.com/Swinject/Swinject)
- [Swinject Best Practices](https://github.com/Swinject/Swinject/blob/master/Documentation/BestPractices.md)
