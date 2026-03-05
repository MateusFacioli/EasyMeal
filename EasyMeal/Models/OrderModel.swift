//
//  OrderModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Foundation

struct OrderModel: Identifiable, Codable {
    let id: String
    let sellerId: String
    let sellerName: String
    let customerId: String
    let customerName: String
    let customerPhone: String
    let items: [OrderItem]
    let total: Double
    var status: OrderStatus
    let paymentMethod: String?
    let notes: String?
    let createdAt: Date
    var estimatedDeliveryTime: Int?
    
    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: total)) ?? "R$ \(total)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, sellerId, sellerName, customerId, customerName, customerPhone
        case items, total, status, paymentMethod, notes, createdAt
        case estimatedDeliveryTime
    }
}

struct OrderItem: Identifiable, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case menuItemId, name, quantity, price
    }
}
