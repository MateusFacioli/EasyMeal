//
//  OrdersHistoryViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine
import FirebaseAuth

class OrdersHistoryViewModel: ObservableObject {
    @Published var orders: [OrderModel] = []
    @Published var isLoading = false
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadOrders(refresh: Bool = false) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        isLoading = true
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.orders)")
            .flatMap { (orders: [OrderModel]) -> AnyPublisher<[OrderModel], Error> in
                // Filtrar pedidos do usuário atual
                let userOrders = orders.filter { $0.customerId == userId }
                return Just(userOrders).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading orders: \(error)")
                    // Fallback para dados mockados
                    self?.loadMockOrders(userId: userId)
                }
            } receiveValue: { [weak self] orders in
                self?.orders = orders
            }
            .store(in: &cancellables)
    }
    
    // Fallback com dados mockados (incluindo sellerName)
    private func loadMockOrders(userId: String) {
        self.orders = [
            OrderModel(
                id: "ORD001",
                sellerId: "SELLER001",
                sellerName: "Lanches do Zé",
                customerId: userId,
                customerName: "Cliente",
                customerPhone: "11999999999",
                items: [
                    OrderItem(
                        menuItemId: "ITEM001",
                        name: "X-Burger",
                        quantity: 2,
                        price: 12.75
                    )
                ],
                total: 25.50,
                status: .delivered,
                paymentMethod: "PIX",
                notes: "Sem cebola",
                createdAt: Date().addingTimeInterval(-86400 * 2),
                estimatedDeliveryTime: 30
            ),
            OrderModel(
                id: "ORD002",
                sellerId: "SELLER002",
                sellerName: "Doces da Maria",
                customerId: userId,
                customerName: "Cliente",
                customerPhone: "11999999999",
                items: [
                    OrderItem(
                        menuItemId: "ITEM002",
                        name: "Brigadeiro",
                        quantity: 6,
                        price: 2.50
                    )
                ],
                total: 15.00,
                status: .preparing,
                paymentMethod: "Cartão",
                notes: nil,
                createdAt: Date().addingTimeInterval(-3600),
                estimatedDeliveryTime: 20
            )
        ]
        self.isLoading = false
    }
    
    func reorder(order: OrderModel) {
        print("Refazendo pedido: \(order.id)")
    }
}
