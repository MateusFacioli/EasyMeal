//
//  MenuTab.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct MenuTab: View {
    let seller: Seller
    @StateObject private var viewModel = MenuTabViewModel()
    @State private var selectedCategory: String = "Todos"
    @State private var selectedItem: MenuItem?
    @State private var showItemDetail = false
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Carregando cardápio...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if viewModel.menuItems.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "menucard")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Cardápio não disponível")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Este comerciante ainda não cadastrou seu cardápio")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                // Categorias
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryChip(
                            title: "Todos",
                            count: viewModel.menuItems.count,
                            isSelected: selectedCategory == "Todos",
                            action: { selectedCategory = "Todos" }
                        )
                        
                        ForEach(viewModel.categories, id: \.self) { category in
                            let count = viewModel.menuItems.filter { $0.category == category }.count
                            CategoryChip(
                                title: category,
                                count: count,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // Itens do Cardápio
                ScrollView {
                    LazyVStack(spacing: 12) {
                        let filteredItems = selectedCategory == "Todos" 
                            ? viewModel.menuItems 
                            : viewModel.menuItems.filter { $0.category == selectedCategory }
                        
                        ForEach(filteredItems) { item in
                            MenuItemCard(item: item)
                                .onTapGesture {
                                    selectedItem = item
                                    showItemDetail = true
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showItemDetail) {
            if let item = selectedItem {
                MenuItemDetailView(item: item, seller: seller)
            }
        }
        .onAppear {
            viewModel.loadMenu(sellerId: seller.id)
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Text("\(count)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isSelected ? Color.white : Color.gray.opacity(0.2))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Menu Item Card
struct MenuItemCard: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 15) {
            // Imagem do Produto
            if let firstImageURL = item.imageURLs.first,
               let url = URL(string: firstImageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    Text(item.formattedPrice)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("\(item.preparationTime) min")
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                }
            }
            
            Spacer()
            
            if item.isAvailable {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Indisponível")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

// MARK: - Menu Item Detail View
struct MenuItemDetailView: View {
    let item: MenuItem
    let seller: Seller
    @Environment(\.presentationMode) var presentationMode
    @State private var quantity = 1
    @State private var specialInstructions = ""
    @State private var showAddToCartConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Imagem do Produto
                    if let firstImageURL = item.imageURLs.first,
                       let url = URL(string: firstImageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(0)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Informações do Produto
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(item.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                if !item.isAvailable {
                                    Text("Indisponível")
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                Label {
                                    Text(item.category)
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: "folder")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                
                                Label {
                                    Text("\(item.preparationTime) min")
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                        
                        // Descrição
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descrição")
                                .font(.headline)
                            
                            Text(item.description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                        
                        // Ingredientes
                        if !item.ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ingredientes")
                                    .font(.headline)
                                
                                Text(item.ingredients.joined(separator: ", "))
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                        }
                        
                        // Observações
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Observações")
                                .font(.headline)
                            
                            TextField("Alguma observação? Ex: sem cebola, ponto da carne...", text: $specialInstructions)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Divider()
                        
                        // Quantidade e Preço
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Quantidade")
                                    .font(.headline)
                                
                                HStack(spacing: 20) {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text("\(quantity)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .frame(width: 40)
                                    
                                    Button(action: { quantity += 1 }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total")
                                    .font(.headline)
                                
                                Text((item.price * Double(quantity)).formattedAsCurrency)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Adicionar") {
                    showAddToCartConfirmation = true
                }
                .disabled(!item.isAvailable)
            )
            .alert("Item Adicionado", isPresented: $showAddToCartConfirmation) {
                Button("Ver Carrinho") {
                    // Navegar para o carrinho
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Continuar Comprando", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("\(item.name) foi adicionado ao seu carrinho.")
            }
        }
    }
}

// MARK: - ViewModel
class MenuTabViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var categories: [String] = []
    @Published var isLoading = false
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadMenu(sellerId: String) {
        isLoading = true
        
        // Primeiro, buscar o seller para pegar o menuId
        databaseService.fetch(path: "\(Constants.FirebasePaths.sellers)/\(sellerId)")
            .flatMap { (seller: Seller) -> AnyPublisher<MenuModel, Error> in
                if let menuId = seller.menuId {
                    return self.databaseService.fetch(path: "\(Constants.FirebasePaths.menus)/\(menuId)")
                } else {
                    return Fail(error: NSError(domain: "MenuTabViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Menu not found"]))
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading menu: \(error)")
                }
            } receiveValue: { [weak self] menu in
                self?.menuItems = menu.items.filter { $0.isAvailable }
                self?.extractCategories(from: menu.items)
            }
            .store(in: &cancellables)
    }
    
    private func extractCategories(from items: [MenuItem]) {
        let uniqueCategories = Set(items.map { $0.category })
        self.categories = Array(uniqueCategories).sorted()
    }
}

// MARK: - Extensão para formatação de moeda
extension Double {
    var formattedAsCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "R$ \(self)"
    }
}

// MARK: - Preview
struct MenuTab_Previews: PreviewProvider {
    static var previews: some View {
        let mockSeller = Seller(
            id: "1",
            userId: "1",
            userEmail: "lanches@ze.com",
            userName: "Zé",
            userPhone: "11999999999",
            businessName: "Lanches do Zé",
            description: "Lanches",
            isOnline: true,
            currentLocation: nil,
            schedules: [],
            menuId: nil,
            rating: 4.5,
            totalReviews: 42,
            isAvailableNow: true,
            address: nil,
            profileImageURL: nil,
            createdAt: Date()
        )
        
        MenuTab(seller: mockSeller)
    }
}