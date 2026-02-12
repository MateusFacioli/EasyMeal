//
//  AuthServiceProtocol.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<User, Error>
    func signUp(email: String, password: String, userData: [String: Any]) -> AnyPublisher<User, Error>
    func signOut() throws
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func updatePhoneNumber(_ phoneNumber: String) -> AnyPublisher<Void, Error>
    var currentUser: User? { get }
}

class AuthService: AuthServiceProtocol {
    private let firebaseManager: FirebaseServiceProtocol
    
    init(firebaseManager: FirebaseServiceProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    var currentUser: User? {
        return firebaseManager.currentUser
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        Future<User, Error> { promise in
            self.firebaseManager.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    promise(.success(user))
                } else {
                    promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signUp(email: String, password: String, userData: [String: Any]) -> AnyPublisher<User, Error> {
        Future<User, Error> { promise in
            self.firebaseManager.auth.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let user = result?.user {
                    // Salvar dados adicionais no Realtime Database
                    let userRef = self.firebaseManager.database.reference().child("users").child(user.uid)
                    userRef.setValue(userData) { error, _ in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(user))
                        }
                    }
                } else {
                    promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signOut() throws {
        try firebaseManager.auth.signOut()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.firebaseManager.auth.sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updatePhoneNumber(_ phoneNumber: String) -> AnyPublisher<Void, Error> {
        // Implementação da verificação de telefone
        Future<Void, Error> { promise in
            // TODO: Implementar verificação de telefone com SMS
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}