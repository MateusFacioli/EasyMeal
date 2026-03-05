//
//  SellerModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import CoreLocation

struct Seller: Identifiable, Codable {
    var id: String
    var userId: String
    var businessName: String
    var description: String
    var isOnline: Bool
    var distance: Double?
    var currentLocation: Location?
    var schedules: [Schedule]
    var menuId: String?
    var rating: Double
    var totalReviews: Int
    var isAvailableNow: Bool
    var profileImageURL: String?
    
    var formattedRating: String {
        return String(format: "%.1f", rating)
    }
    
    var hasSchedules: Bool {
        return !schedules.isEmpty
    }
    
    var hasMenu: Bool {
        return menuId != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id, userId, businessName, description, isOnline
        case distance, currentLocation, schedules, menuId
        case rating, totalReviews, isAvailableNow, profileImageURL
    }
}

struct Schedule: Identifiable, Codable {
    var id: String
    var dayOfWeek: Int // 1-7 (Sunday-Saturday)
    var startTime: Date
    var endTime: Date
    var location: Location
    var isActive: Bool
    
    var dayName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        return dateFormatter.weekdaySymbols[dayOfWeek - 1]
    }
}

struct Location: Identifiable, Codable {
    var id = UUID()
    var latitude: Double
    var longitude: Double
    var address: String?
    var placeName: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, address, placeName
    }
}
