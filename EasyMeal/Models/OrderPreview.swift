//
//  OrderPreview.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct OrderPreview: Identifiable {
    let id: String
    let customerName: String
    let total: Double
    let status: OrderStatus
    let createdAt: Date
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: total)) ?? "R$ \(total)"
    }
}

enum OrderStatus: String, Codable {
    case pending = "Pendente"
    case confirmed = "Confirmado"
    case preparing = "Preparando"
    case ready = "Pronto"
    case delivered = "Entregue"
    case cancelled = "Cancelado"
}
