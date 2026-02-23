//
//  BuyerProfileViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Combine
import Foundation
import FirebaseAuth

class BuyerProfileViewModel: ObservableObject {
    @Published var buyer: Buyer?
    @Published var totalOrders = 0
    @Published var totalFavorites = 0
    @Published var totalRatings = 0
    @Published var searchRadius: Double = 1000
    @Published var notificationsEnabled = true
    @Published var preferredPayment: String? = "PIX"
    @Published var recentOrders: [Order] = []
    @Published var isLoading = false
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadBuyerProfile(userId: String) {
        
        isLoading = true
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.buyers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading buyer profile: \(error)")
                }
            } receiveValue: { [weak self] (buyer: Buyer) in
                self?.buyer = buyer
                self?.searchRadius = buyer.searchRadius
                self?.notificationsEnabled = buyer.notificationPreferences.favoriteSellerOnline
                self?.loadStatistics(userId: userId)
                self?.loadRecentOrders(userId: userId)
            }
            .store(in: &cancellables)
    }
    
    private func loadStatistics(userId: String) {
        // TODO: Carregar estatísticas reais do Firebase
        // Por enquanto, dados mockados
        self.totalOrders = 8
        self.totalFavorites = 3
        self.totalRatings = 5
    }
    
    private func loadRecentOrders(userId: String) {
        // TODO: Carregar pedidos reais do Firebase
        // Por enquanto, dados mockados
        self.recentOrders = [
            Order(
                id: "ORD001",
                sellerId: "SELLER001",
                sellerName: "Lanches do Zé",
                customerId: userId,
                customerName: "Cliente",
                customerPhone: "11999999999",
                items: [],
                total: 25.50,
                status: .delivered,
                paymentMethod: "PIX",
                notes: nil,
                createdAt: Date().addingTimeInterval(-86400),
                estimatedDeliveryTime: 45
            ),
            Order(
                id: "ORD002",
                sellerId: "SELLER002",
                sellerName: "Doces da Maria",
                customerId: userId,
                customerName: "Cliente",
                customerPhone: "11999999999",
                items: [],
                total: 15.00,
                status: .preparing,
                paymentMethod: "Cartão",
                notes: nil,
                createdAt: Date(),
                estimatedDeliveryTime: 45
            )
        ]
    }
}
