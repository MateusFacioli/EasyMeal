//
//  ContentView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 06/02/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                MainHomeView()
            }
        }
        .animation(.default, value: authViewModel.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
