//
//  ContentView.swift
//  ButterflyChallenge
//
//  Created by Francisco Rosso on 24/11/2025.
//

import SwiftUI

struct ContentView: View {
    let viewModel: MovieSearchViewModel
    
    init() {
        self.viewModel = DependencyContainer.shared.makeMoviesViewModel()
    }
    
    var body: some View {
        MovieSearchView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
}
