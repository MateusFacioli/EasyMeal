struct Order: Identifiable {
    let id: String
    let sellerId: String
    let customerId: String
    let customerName: String
    let customerPhone: String
    let items: [OrderItem]
    let total: Double
    var status: OrderStatus
    let paymentMethod: String?
    let notes: String?
    let createdAt: Date
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: total)) ?? "R$ \(total)"
    }
}