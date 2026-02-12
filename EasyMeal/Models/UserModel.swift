//
//  UserModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 06/02/26.
//

import Foundation

enum UserType: String, Codable {
    case seller
    case buyer
}

struct UserModel: Codable {
    let email: String?
    let psw: String?
    let name: String?
    let cpf_cnpj: String?
    let phone: String?
    let address: String?
    let userType: UserType
    let isPhoneVerified: Bool
    let profileImageURL: String?
    let createdAt: Date
}
