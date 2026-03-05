//
//  BuyerModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation

struct Buyer: Identifiable, Codable {
    var id: String
    var userId: String
    var favoriteSellerIds: [String]?
    var searchRadius: Double // in meters
    var notificationPreferences: NotificationPreferences
    var profileImageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id, userId, favoriteSellerIds, searchRadius
        case notificationPreferences, profileImageURL
    }
}

struct NotificationPreferences: Codable {
    var favoriteSellerOnline: Bool = true
    var newOffersNearby: Bool = true
    var orderUpdates: Bool = true
    var promotions: Bool = true
}
