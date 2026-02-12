class OrdersHistoryViewModel: ObservableObject {
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
                    createdAt: Date().addingTimeInterval(-86400 * 2) // 2 dias atrás
                ),
                Order(
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
                    createdAt: Date().addingTimeInterval(-3600) // 1 hora atrás
                ),
                Order(
                    id: "ORD003",
                    sellerId: "SELLER003",
                    sellerName: "Sucos Naturais João",
                    customerId: userId,
                    customerName: "Cliente",
                    customerPhone: "11999999999",
                    items: [
                        OrderItem(
                            menuItemId: "ITEM003",
                            name: "Suco de Laranja",
                            quantity: 1,
                            price: 8.00
                        )
                    ],
                    total: 8.00,
                    status: .cancelled,
                    paymentMethod: "Dinheiro",
                    notes: "Cancelado pelo cliente",
                    createdAt: Date().addingTimeInterval(-86400 * 5) // 5 dias atrás
                )
            ]
            self.isLoading = false
        }
        
        // TODO: Implementar carregamento real do Firebase
        // databaseService.fetch(path: "\(Constants.FirebasePaths.orders)/\(userId)")
    }
    
    func reorder(order: Order) {
        // Implementar lógica para refazer pedido
        print("Refazendo pedido: \(order.id)")
        
        // Aqui você poderia:
        // 1. Navegar para a página do seller
        // 2. Pré-selecionar os itens do pedido anterior
        // 3. Iniciar um novo pedido
    }
}