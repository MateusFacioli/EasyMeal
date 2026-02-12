//
//  Constants.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation

struct Constants {
    struct FirebasePaths {
        static let users = "users"
        static let sellers = "sellers"
        static let buyers = "buyers"
        static let menus = "menus"
        static let schedules = "schedules"
        static let orders = "orders"
        static let menuItems = "menu_items"
    }
    
    struct UserDefaultsKeys {
        static let userType = "user_type"
        static let isFirstLaunch = "is_first_launch"
        static let searchRadius = "search_radius"
        static let notificationEnabled = "notification_enabled"
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
