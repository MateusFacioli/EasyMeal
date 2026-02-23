//
//  BuyerHomeView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine
import MapKit

struct BuyerHomeView: View {
    @StateObject private var viewModel = BuyerHomeViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showFilters = false
    @State private var selectedSeller: Seller? = nil
    @State private var showSellerDetail = false
    
    // Region for the map
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // MARK: - Computed Properties
    var mapAnnotations: [SellerAnnotation] {
        var annotations = filteredSellers.map { $0.toAnnotation() }
        if let buyerLocation = viewModel.buyerLocation {
            annotations.append(buyerAnnotation)
        }
        return annotations
    }
    
    var filteredSellers: [Seller] {
        var sellers = viewModel.nearbySellers
        
        // Filter only online sellers
        sellers = sellers.filter { $0.isOnline }
        
        // Filter by distance within selected radius
        if let buyerLocation = viewModel.buyerLocation {
            sellers = sellers.filter {
                if let sellerLoc = $0.currentLocation {
                    let sellerLocation = CLLocation(latitude: sellerLoc.latitude, longitude: sellerLoc.longitude)
                    return sellerLocation.distance(from: buyerLocation) <= viewModel.searchRadius
                }
                return false
            }
        }
        
        // Filter by category if selected
        if let category = selectedCategory, category != "Todos" {
            sellers = sellers.filter { $0.description.localizedCaseInsensitiveContains(category) }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            sellers = sellers.filter {
                $0.businessName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return sellers
    }
    
    private var buyerAnnotation: SellerAnnotation {
        if let loc = viewModel.buyerLocation {
            return SellerAnnotation(
                id: "buyer_location",
                title: "Você",
                coordinate: loc.coordinate,
                isBuyer: true
            )
        }
        return SellerAnnotation(
            id: "buyer_location",
            title: "Você",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            isBuyer: true
        )
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            mapView
            overlayContent
        }
        .navigationTitle("Descobrir")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
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
            if let buyerLoc = viewModel.buyerLocation {
                updateRegion(to: buyerLoc.coordinate)
            }
        }
        .onChange(of: viewModel.buyerLocation) { newLocation in
            if let loc = newLocation {
                updateRegion(to: loc.coordinate)
            }
        }
        .onChange(of: viewModel.nearbySellers.count) { _ in
            if let loc = viewModel.buyerLocation {
                updateRegion(to: loc.coordinate)
            }
        }
    }
    
    // MARK: - Map View Component
    @ViewBuilder
    private var mapView: some View {
        if let _ = viewModel.buyerLocation {
            Map(coordinateRegion: $region, annotationItems: mapAnnotations) { item in
                // CORRIGIDO: Usar MapMarker para simplificar
                if item.isBuyer {
                    MapMarker(coordinate: item.coordinate, tint: .blue)
                } else {
                    MapMarker(coordinate: item.coordinate, tint: .red)
                }
            }
            .ignoresSafeArea()
        } else {
            Color(.systemGray6)
                .ignoresSafeArea()
        }
    }
    
    // MARK: - Overlay Content
    private var overlayContent: some View {
        VStack(spacing: 0) {
            // Search Bar
            VStack(spacing: 15) {
                searchBar
                categoryScroll
            }
            .padding()
            .background(Color(.systemBackground).opacity(0.9))
            
            Spacer()
            
            // Lista de Comerciantes
            sellersList
        }
        .padding(.top, 44)
    }
    
    // MARK: - Search Bar Component
    private var searchBar: some View {
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
        .background(Color(.systemBackground).opacity(0.9))
        .cornerRadius(10)
    }
    
    // MARK: - Category Scroll Component
    private var categoryScroll: some View {
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
    
    // MARK: - Sellers List Component
    @ViewBuilder
    private var sellersList: some View {
        if viewModel.isLoading {
            ProgressView("Carregando comerciantes...")
                .frame(maxHeight: .infinity)
                .background(Color(.systemBackground).opacity(0.9))
        } else if filteredSellers.isEmpty {
            emptyStateView
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
            .frame(maxHeight: 260)
            .background(Color(.systemBackground).opacity(0.9))
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
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
        .background(Color(.systemBackground).opacity(0.9))
    }
    
    // MARK: - Toolbar Content
    private var toolbarContent: some ToolbarContent {
        Group {
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
    }
    
    // MARK: - Helper Methods
    private func updateRegion(to location: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}

// MARK: - Annotation Wrapper
struct SellerAnnotation: Identifiable, Equatable {
    let id: String
    let title: String?
    let coordinate: CLLocationCoordinate2D
    var isBuyer: Bool = false
    
    static func == (lhs: SellerAnnotation, rhs: SellerAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Seller Extension
extension Seller {
    func toAnnotation() -> SellerAnnotation {
        if let loc = currentLocation {
            return SellerAnnotation(
                id: id,
                title: businessName,
                coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            )
        } else {
            return SellerAnnotation(
                id: id,
                title: businessName,
                coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)
            )
        }
    }
}
