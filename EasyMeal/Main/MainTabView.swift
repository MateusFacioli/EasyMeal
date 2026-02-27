//
//  MainTabView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            switch (authViewModel.isAuthenticated, authViewModel.currentUser) {
            case (false, _):
                // Not authenticated: show the lightweight entry (MainHomeView) instead of blank
                MainHomeView()
                    .environmentObject(authViewModel)
            case (true, .some(let user)):
                if user.isSeller {
                    SellerTabView()
                } else {
                    BuyerTabView()
                }
            case (true, .none):
                // Authenticated but user not hydrated: show progress with retry
                VStack(spacing: 12) {
                    ProgressView("Carregando... maintabview")
                    Button("Tentar novamente") {
                        authViewModel.refreshCurrentUser()
                    }
                    .font(.footnote)
                }
                .onAppear {
                    // Avoid tight loops: only fetch if we don't have it yet
                    if authViewModel.currentUser == nil {
                        authViewModel.refreshCurrentUser()
                    }
                }
            }
        }
    }
}

struct SellerTabView: View {
    var body: some View {
        TabView {
            SellerDashboardView()
                .tabItem {
                    Label("Início", systemImage: "house.fill")
                }
            
            FinancialView()
                .tabItem {
                    Label("Financeiro", systemImage: "dollarsign.circle")
                }
            
            OrdersView()
                .tabItem {
                    Label("Pedidos", systemImage: "cart.fill")
                }
            
            SellerProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
        .accentColor(.blue)
    }
}

struct BuyerTabView: View {
    var body: some View {
        TabView {
            BuyerHomeView()
                .tabItem {
                    Label("Descobrir", systemImage: "magnifyingglass")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favoritos", systemImage: "heart.fill")
                }
            
            OrdersHistoryView()
                .tabItem {
                    Label("Pedidos", systemImage: "clock.fill")
                }
            
            BuyerProfileView()
                .tabItem {
                    Label("Perfil", systemImage: "person.fill")
                }
        }
        .accentColor(.green)
    }
}

