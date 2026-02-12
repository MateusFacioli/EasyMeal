//
//  FirebaseManager.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol FirebaseServiceProtocol {
    var auth: Auth { get }
    var database: Database { get }
    var storage: Storage { get }
    var currentUser: User? { get }
    func configure()
}

class FirebaseManager: FirebaseServiceProtocol {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let database: Database
    let storage: Storage
    
    var currentUser: User? {
        return auth.currentUser
    }
    
    private init() {
        self.auth = Auth.auth()
        self.database = Database.database()
        self.storage = Storage.storage()
    }
    
    func configure() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Configurar persistência do Realtime Database
        Database.database().isPersistenceEnabled = true
        
        // Configurar timeout do Storage
        Storage.storage().maxOperationRetryTime = 120
    }
}
