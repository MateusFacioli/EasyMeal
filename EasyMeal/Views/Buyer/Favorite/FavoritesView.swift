//
//  FavoritesView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedCategory: String? = nil
    @State private var searchText = ""
    @State private var selectedSeller: Seller? = nil
    @State private var showSellerDetail = false
    
    var filteredSellers: [Seller] {
        var sellers = viewModel.favoriteSellers
        
        // Filtrar por categoria se selecionada
        if let category = selectedCategory, category != "Todos" {
            sellers = sellers.filter { $0.description.localizedCaseInsensitiveContains(category) }
        }
        
        // Filtrar por busca
        if !searchText.isEmpty {
            sellers = sellers.filter {
                $0.businessName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Ordenar por online primeiro
        return sellers.sorted { $0.isOnline && !$1.isOnline }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Buscar nos favoritos...", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()
            
            // Categorias
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    CategoryChip(
                        title: "Todos",
                        count: 3,
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(viewModel.categories, id: \.self) { category in
                        CategoryChip(
                            title: category,
                            count: 4,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            if viewModel.isLoading {
                ProgressView("Carregando favoritos...")
                    .frame(maxHeight: .infinity)
            } else if filteredSellers.isEmpty {
                EmptyFavoritesView(searchText: searchText)
            } else {
                // Lista de Favoritos
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredSellers) { seller in
                            FavoriteSellerCard(seller: seller, isFavorite: true)
                                .onTapGesture {
                                    selectedSeller = seller
                                    showSellerDetail = true
                                }
                                .contextMenu {
                                    Button(action: {
                                        viewModel.removeFromFavorites(sellerId: seller.id)
                                    }) {
                                        Label("Remover dos Favoritos", systemImage: "heart.slash")
                                    }
                                    
                                    Button(action: {
                                        // Compartilhar
                                    }) {
                                        Label("Compartilhar", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSellerDetail) {
            if let seller = selectedSeller {
                SellerDetailView(seller: seller)
            }
        }
        .onAppear {
            viewModel.loadFavoriteSellers()
        }
    }
}
