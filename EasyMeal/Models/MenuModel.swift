//
//  MenuModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation

struct MenuModel: Identifiable, Codable {
    var id: String
    var sellerId: String
    var items: [MenuItem]
    var categories: [String]
    var isActive: Bool
    var lastUpdated: Date
}

struct MenuItem: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var price: Double
    var category: String
    var imageURLs: [String]
    var isAvailable: Bool
    var preparationTime: Int // in minutes
    var ingredients: [String]
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: price)) ?? "R$ \(price)"
    }
}
