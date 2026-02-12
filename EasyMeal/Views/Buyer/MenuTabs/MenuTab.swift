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

// MARK: - Preview
//struct MenuTab_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockSeller = Seller(
//            id: "1",
//            userId: "1",
//            userEmail: "lanches@ze.com",
//            userName: "Zé",
//            userPhone: "11999999999",
//            businessName: "Lanches do Zé",
//            description: "Lanches",
//            isOnline: true,
//            currentLocation: nil,
//            schedules: [],
//            menuId: nil,
//            rating: 4.5,
//            totalReviews: 42,
//            isAvailableNow: true,
//            address: nil,
//            profileImageURL: nil,
//            createdAt: Date()
//        )
//        
//        MenuTab(seller: mockSeller)
//    }
//}
