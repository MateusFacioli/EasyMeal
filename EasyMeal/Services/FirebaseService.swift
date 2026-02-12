//
//  FirebaseService.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FirebaseService {
    static let shared = FirebaseService()
    
    private init() {}
    
    let auth = Auth.auth()
    let database = Database.database()
    let storage = Storage.storage()
    
    var databaseRef: DatabaseReference {
        return database.reference()
    }
    
    var storageRef: StorageReference {
        return storage.reference()
    }
    
    var currentUserId: String? {
        return auth.currentUser?.uid
    }
    
    func configure() {
        // Configurações adicionais do Firebase podem ser feitas aqui
    }
}