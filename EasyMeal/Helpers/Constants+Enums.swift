//
//  Constants+Enums.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation

struct Constants {
    struct FirebasePaths {
        // Database paths
        static let users = "users"
        static let sellers = "sellers"
        static let buyers = "buyers"
        static let menus = "menus"
        static let schedules = "schedules"
        static let orders = "orders"
        static let reviews = "reviews"
        // Storage paths
        static let menuItems = "menu_items"
        static let reviewsImages = "reviews_mages"
        static let profileImages = "profiles"
        
    }
    
    struct UserDefaultsKeys {
        static let userType = "user_type"
        static let isFirstLaunch = "is_first_launch"
        static let searchRadius = "search_radius"
        static let notificationEnabled = "notification_enabled"
        static let authVerificationID = "authVerificationID"
    }
    
    struct Validation {
        static let minPasswordLength = 6
    }
}

enum OrderFilter: String, CaseIterable {
    case all = "Todos"
    case pending = "Pendentes"
    case confirmed = "Confirmados"
    case preparing = "Preparando"
    case ready = "Prontos"
    
    var title: String {
        return self.rawValue
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

enum OrderHistoryFilter: String, CaseIterable {
    case all = "Todos"
    case pending = "Em Andamento"
    case completed = "Concluídos"
    case cancelled = "Cancelados"
    
    var title: String {
        return self.rawValue
    }
}

enum SortOption: String, CaseIterable {
    case distance = "Distância"
    case rating = "Avaliação"
    case name = "Nome"
}

enum UserType: String, Codable {
    case seller
    case buyer
}

enum UserTypeSelection {
    case seller
    case buyer
    case none
}
