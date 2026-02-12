//
//  BuyerHomeView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI
import Combine

struct BuyerHomeView: View {
    @StateObject private var viewModel = BuyerHomeViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showFilters = false
    @State private var selectedSeller: Seller? = nil
    @State private var showSellerDetail = false
    
    var filteredSellers: [Seller] {
        var sellers = viewModel.nearbySellers
        
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
        
        return sellers
    }
    
    var body: some View {
        ZStack {
            // Mapa (usaremos mais tarde)
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Buscar comércios...", text: $searchText)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    
                    // Filtro por categoria
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            CategoryButton(
                                title: "Todos",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(viewModel.categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // Lista de Comerciantes
                if viewModel.isLoading {
                    ProgressView("Carregando comerciantes...")
                        .frame(maxHeight: .infinity)
                } else if filteredSellers.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "storefront")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text(searchText.isEmpty ? 
                             "Nenhum comerciante próximo" : 
                             "Nenhum resultado para '\(searchText)'")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        if searchText.isEmpty {
                            Button("Atualizar Localização") {
                                viewModel.refreshLocation()
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredSellers) { seller in
                                SellerCard(seller: seller)
                                    .onTapGesture {
                                        selectedSeller = seller
                                        showSellerDetail = true
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Descobrir")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showFilters = true }) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.refreshLocation() }) {
                    Image(systemName: "location.fill")
                }
            }
        }
        .sheet(isPresented: $showFilters) {
            FilterView(
                radius: $viewModel.searchRadius,
                showOnlyOpen: $viewModel.showOnlyOpen,
                sortBy: $viewModel.sortBy
            )
        }
        .sheet(isPresented: $showSellerDetail) {
            if let seller = selectedSeller {
                SellerDetailView(seller: seller)
            }
        }
        .onAppear {
            viewModel.loadNearbySellers()
        }
    }
}
