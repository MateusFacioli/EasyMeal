//
//  Review.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let sellerId: String
    let userId: String
    let userName: String
    let rating: Int
    let comment: String
    let imageURLs: [String]
    let date: Date
    let helpfulCount: Int
    let sellerReply: SellerReply?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

struct SellerReply: Codable {
    let comment: String
    let date: Date
}
