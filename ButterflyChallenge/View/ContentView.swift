//
//  ContentView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI
import Security

struct ContentView: View {
    let searchViewModel: MovieSearchViewModel
    let favoritesViewModel: FavoritesViewModel
    
    init() {
        self.searchViewModel = DependencyContainer.shared.makeMoviesViewModel()
        self.favoritesViewModel = DependencyContainer.shared.makeFavoritesViewModel()
    }
    
    var body: some View {
        TabView {
            MovieSearchView(viewModel: searchViewModel)
                .tabItem {
                    Label("tab.search".localized(), systemImage: "magnifyingglass")
                }
            
            FavoritesView(viewModel: favoritesViewModel)
                .tabItem {
                    Label("tab.favorites".localized(), systemImage: "heart.fill")
                }
        }
    }
}
