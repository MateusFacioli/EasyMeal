//
//  OrdersViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Combine
import FirebaseAuth

class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var isLoading = false
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadOrders(refresh: Bool = false) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        isLoading = true
        
        // Por enquanto, dados mockados
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.orders = [
                Order(
                    id: "ORD001",
                    sellerId: userId,
                    customerId: "CUST001",
                    customerName: "João Silva",
                    customerPhone: "11999999999",
                    items: [
                        OrderItem(
                            menuItemId: "ITEM001",
                            name: "X-Burger",
                            quantity: 2,
                            price: 12.75
                        ),
                        OrderItem(
                            menuItemId: "ITEM002",
                            name: "Coca-Cola 350ml",
                            quantity: 2,
                            price: 5.00
                        )
                    ],
                    total: 35.50,
                    status: .pending,
                    paymentMethod: "PIX",
                    notes: "Sem cebola",
                    createdAt: Date()
                ),
                Order(
                    id: "ORD002",
                    sellerId: userId,
                    customerId: "CUST002",
                    customerName: "Maria Santos",
                    customerPhone: "11988888888",
                    items: [
                        OrderItem(
                            menuItemId: "ITEM003",
                            name: "Batata Frita",
                            quantity: 1,
                            price: 15.00
                        )
                    ],
                    total: 15.00,
                    status: .confirmed,
                    paymentMethod: "Cartão",
                    notes: nil,
                    createdAt: Date().addingTimeInterval(-3600)
                ),
                Order(
                    id: "ORD003",
                    sellerId: userId,
                    customerId: "CUST003",
                    customerName: "Pedro Oliveira",
                    customerPhone: "11977777777",
                    items: [
                        OrderItem(
                            menuItemId: "ITEM001",
                            name: "X-Burger",
                            quantity: 1,
                            price: 12.75
                        ),
                        OrderItem(
                            menuItemId: "ITEM004",
                            name: "Sorvete",
                            quantity: 1,
                            price: 8.50
                        )
                    ],
                    total: 21.25,
                    status: .preparing,
                    paymentMethod: "Dinheiro",
                    notes: "Para viagem",
                    createdAt: Date().addingTimeInterval(-7200)
                )
            ]
            self.isLoading = false
        }
        
        // TODO: Implementar carregamento real do Firebase
        // databaseService.fetch(path: "\(Constants.FirebasePaths.orders)/\(userId)")
    }
    
    func updateOrderStatus(_ orderId: String, to status: OrderStatus) {
        // Atualizar localmente
        if let index = orders.firstIndex(where: { $0.id == orderId }) {
            orders[index].status = status
        }
        
        // Atualizar no Firebase
        let data: [String: Any] = [
            "status": status.rawValue,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        databaseService.update(path: "\(Constants.FirebasePaths.orders)/\(orderId)", data: data)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error updating order: \(error)")
                }
            } receiveValue: { }
            .store(in: &cancellables)
    }
}
