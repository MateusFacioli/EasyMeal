//
//  UserModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 06/02/26.
//

import Foundation

struct UserModel: Identifiable, Codable {
    var id: String = UUID().uuidString
    var email: String
    var psw: String?
    var name: String
    var cpf_cnpj: String
    var phone: String
    var address: String?
    var userType: UserType
    var isPhoneVerified: Bool = false
    var profileImageURL: String?
    var createdAt: Date = Date()
    var fcmToken: String?
    
    // Propriedades computadas para facilitar
    var isSeller: Bool {
        return userType == .seller
    }
    
    var isBuyer: Bool {
        return userType == .buyer
    }
    
    var formattedDocument: String {
        if userType == .seller {
            return Validators.formatCNPJ(cpf_cnpj)
        } else {
            return Validators.formatCPF(cpf_cnpj)
        }
    }
    
    var formattedPhone: String {
        let numbers = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if numbers.count == 11 {
            return "(\(numbers.prefix(2))) \(numbers.dropFirst(2).prefix(5))-\(numbers.dropFirst(7))"
        } else if numbers.count == 10 {
            return "(\(numbers.prefix(2))) \(numbers.dropFirst(2).prefix(4))-\(numbers.dropFirst(6))"
        }
        return phone
    }
}
