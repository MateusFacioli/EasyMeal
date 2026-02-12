//
//  BuyerHomeView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

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

// MARK: - Componentes
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SellerCard: View {
    let seller: Seller
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                // Imagem do Comerciante
                if let profileImageURL = seller.profileImageURL,
                   let url = URL(string: profileImageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "storefront.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "storefront.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(seller.businessName)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if seller.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    if !seller.description.isEmpty {
                        Text(seller.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    // Rating
                    if seller.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text(seller.formattedRating)
                                .font(.caption2)
                                .fontWeight(.semibold)
                            
                            Text("(\(seller.totalReviews))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            // Informações adicionais
            HStack {
                Label {
                    Text(seller.isAvailableNow ? "Aberto agora" : "Fechado")
                        .font(.caption2)
                        .foregroundColor(seller.isAvailableNow ? .green : .red)
                } icon: {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                }
                
                Spacer()
                
                if let distance = seller.distance {
                    Label {
                        Text(String(format: "%.1f km", distance))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } icon: {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

// MARK: - ViewModel
class BuyerHomeViewModel: ObservableObject {
    @Published var nearbySellers: [Seller] = []
    @Published var categories: [String] = ["Lanches", "Bebidas", "Doces", "Salgados", "Saudável"]
    @Published var isLoading = false
    @Published var searchRadius: Double = 1000 // 1km default
    @Published var showOnlyOpen = true
    @Published var sortBy: SortOption = .distance
    
    private let databaseService: DatabaseServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.databaseService = databaseService
        self.locationService = locationService
    }
    
    func loadNearbySellers() {
        isLoading = true
        
        // Primeiro, obter localização atual
        locationService.getCurrentLocation()
            .flatMap { [weak self] userLocation -> AnyPublisher<[Seller], Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "BuyerHomeViewModel", code: -1, userInfo: nil))
                        .eraseToAnyPublisher()
                }
                
                // Buscar todos os sellers do Firebase
                return self.databaseService.fetch(path: Constants.FirebasePaths.sellers)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading sellers: \(error)")
                }
            } receiveValue: { [weak self] sellersDict in
                // Convert dictionary to array
                var sellers: [Seller] = []
                for (_, value) in sellersDict {
                    if let sellerData = value as? [String: Any] {
                        // Converter para Seller
                        // Implementar decodificação apropriada
                    }
                }
                
                // Por enquanto, dados mockados
                self?.loadMockSellers()
            }
            .store(in: &cancellables)
    }
    
    private func loadMockSellers() {
        // Dados mockados para teste
        self.nearbySellers = [
            Seller(
                id: "1",
                userId: "1",
                userEmail: "lanches@ze.com",
                userName: "Zé",
                userPhone: "11999999999",
                businessName: "Lanches do Zé",
                description: "Os melhores lanches da região",
                isOnline: true,
                currentLocation: Location(latitude: -23.5505, longitude: -46.6333, address: "Rua Exemplo, 123"),
                schedules: [],
                menuId: nil,
                rating: 4.5,
                totalReviews: 42,
                isAvailableNow: true,
                address: "Rua Exemplo, 123",
                profileImageURL: nil,
                createdAt: Date()
            ),
            Seller(
                id: "2",
                userId: "2",
                userEmail: "doces@maria.com",
                userName: "Maria",
                userPhone: "11988888888",
                businessName: "Doces da Maria",
                description: "Doces caseiros e sobremesas",
                isOnline: true,
                currentLocation: Location(latitude: -23.5510, longitude: -46.6340),
                schedules: [],
                menuId: nil,
                rating: 4.8,
                totalReviews: 28,
                isAvailableNow: true,
                address: "Av. Principal, 456",
                profileImageURL: nil,
                createdAt: Date()
            ),
            Seller(
                id: "3",
                userId: "3",
                userEmail: "sucos@joao.com",
                userName: "João",
                userPhone: "11977777777",
                businessName: "Sucos Naturais João",
                description: "Sucos frescos e saudáveis",
                isOnline: false,
                currentLocation: Location(latitude: -23.5520, longitude: -46.6350),
                schedules: [],
                menuId: nil,
                rating: 4.2,
                totalReviews: 15,
                isAvailableNow: false,
                address: "Praça Central, 789",
                profileImageURL: nil,
                createdAt: Date()
            )
        ]
        
        // Adicionar distância fictícia
        for i in 0..<self.nearbySellers.count {
            self.nearbySellers[i].distance = Double.random(in: 0.5...5.0)
        }
    }
    
    func refreshLocation() {
        loadNearbySellers()
    }
}

// MARK: - Views Auxiliares
struct FilterView: View {
    @Binding var radius: Double
    @Binding var showOnlyOpen: Bool
    @Binding var sortBy: SortOption
    @Environment(\.presentationMode) var presentationMode
    
    let radiusOptions: [Double] = [500, 1000, 2000, 5000, 10000]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Distância")) {
                    Picker("Raio de busca", selection: $radius) {
                        ForEach(radiusOptions, id: \.self) { value in
                            Text("\(Int(value)) metros").tag(value)
                        }
                    }
                }
                
                Section(header: Text("Filtros")) {
                    Toggle("Mostrar apenas abertos", isOn: $showOnlyOpen)
                }
                
                Section(header: Text("Ordenar por")) {
                    Picker("Ordenar", selection: $sortBy) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Filtros")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Aplicar") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct SellerDetailView: View {
    let seller: Seller
    @Environment(\.presentationMode) var presentationMode
    @State private var showMenu = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header com imagem
                    ZStack(alignment: .bottom) {
                        Color.blue.opacity(0.1)
                            .frame(height: 150)
                        
                        VStack(spacing: 10) {
                            Image(systemName: "storefront.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text(seller.businessName)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    // Tabs
                    HStack {
                        TabButton(title: "Sobre", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "Cardápio", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabButton(title: "Horários", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                        
                        TabButton(title: "Avaliações", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    
                    // Conteúdo da Tab
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            AboutTab(seller: seller)
                        } else if selectedTab == 1 {
                            MenuTab(seller: seller, showMenu: $showMenu)
                        } else if selectedTab == 2 {
                            ScheduleTab(seller: seller)
                        } else {
                            ReviewsTab(seller: seller)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Fechar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// ... [continua com as outras views do cliente]

// MARK: - Enums
enum SortOption: String, CaseIterable {
    case distance = "Distância"
    case rating = "Avaliação"
    case name = "Nome"
}