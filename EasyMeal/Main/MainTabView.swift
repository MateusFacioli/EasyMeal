//
//  MainTabView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    //MARK: TODO SEM E COM .environmentObject(authViewModel) ESTÁ FICANDO NO FALLBACK PROGRESSVIEW
    var body: some View {
        Group {
            if let user = authViewModel.currentUser {
                if user.isSeller {
                    SellerTabView().environmentObject(authViewModel)
                } else {
                    BuyerTabView().environmentObject(authViewModel)
                }
            } else {
                ProgressView("Carregando...")
            }
        }
        .onAppear {
            // Se o usuário ainda não estiver carregado, tente inicializar/atualizar
            // Caso seu AuthViewModel possua algum método de refresh, chame-o aqui.
            // Ex: authViewModel.refreshCurrentUser()
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

