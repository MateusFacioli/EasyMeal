struct OrderItem: Identifiable {
    let id = UUID().uuidString
    let menuItemId: String
    let name: String
    let quantity: Int
    let price: Double
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: price)) ?? "R$ \(price)"
    }
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        let total = price * Double(quantity)
        return formatter.string(from: NSNumber(value: total)) ?? "R$ \(total)"
    }
}