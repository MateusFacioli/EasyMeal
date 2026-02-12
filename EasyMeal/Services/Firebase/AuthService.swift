//
//  AuthService.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<UserModel, Error>
    func signUp(user: UserModel, password: String, businessName: String?) -> AnyPublisher<UserModel, Error>
    func signOut() throws
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func updatePhoneNumber(_ phoneNumber: String) -> AnyPublisher<Void, Error>
    var currentUser: User? { get }
}

class AuthService: AuthServiceProtocol {
    private let firebaseManager: FirebaseServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(firebaseManager: FirebaseServiceProtocol = FirebaseManager.shared,
         databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.firebaseManager = firebaseManager
        self.databaseService = databaseService
    }
    
    var currentUser: User? {
        return firebaseManager.currentUser
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<UserModel, Error> {
        Future<UserModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])))
                return
            }
            
            self.firebaseManager.auth.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let firebaseUser = result?.user {
                    // Buscar dados do usuário no Realtime Database
                    self.fetchUserFromDatabase(userId: firebaseUser.uid)
                        .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                promise(.failure(error))
                            }
                        }, receiveValue: { userModel in
                            promise(.success(userModel))
                        })
                        .store(in: &self.cancellables)
                } else {
                    promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func signUp(user: UserModel, password: String, businessName: String? = nil) -> AnyPublisher<UserModel, Error> {
        Future<UserModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])))
                return
            }
            
            self.firebaseManager.auth.createUser(withEmail: user.email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                } else if let firebaseUser = result?.user {
                    // Atualizar ID do usuário com o ID do Firebase
                    var newUser = user
                    newUser.id = firebaseUser.uid
                    
                    // Salvar dados do usuário no Realtime Database
                    self.saveUserToDatabase(user: newUser)
                        .flatMap { _ -> AnyPublisher<Void, Error> in
                            // Criar perfil específico (Seller ou Buyer)
                            if newUser.userType == .seller, let businessName = businessName {
                                let seller = Seller(
                                    id: newUser.id,
                                    userId: newUser.id,
                                    userEmail: newUser.email,
                                    userName: newUser.name,
                                    userPhone: newUser.phone,
                                    businessName: businessName,
                                    description: "",
                                    isOnline: false,
                                    currentLocation: nil,
                                    schedules: [],
                                    menuId: nil,
                                    rating: 0.0,
                                    totalReviews: 0,
                                    isAvailableNow: false,
                                    address: newUser.address,
                                    profileImageURL: newUser.profileImageURL,
                                    createdAt: newUser.createdAt
                                )
                                return self.databaseService.save(seller, path: "\(Constants.FirebasePaths.sellers)/\(newUser.id)")
                            } else if newUser.userType == .buyer {
                                let buyer = Buyer(
                                    id: newUser.id,
                                    userId: newUser.id,
                                    userEmail: newUser.email,
                                    userName: newUser.name,
                                    userPhone: newUser.phone,
                                    favoriteSellerIds: [],
                                    searchRadius: 1000,
                                    notificationPreferences: NotificationPreferences(),
                                    address: newUser.address,
                                    profileImageURL: newUser.profileImageURL,
                                    createdAt: newUser.createdAt
                                )
                                return self.databaseService.save(buyer, path: "\(Constants.FirebasePaths.buyers)/\(newUser.id)")
                            } else {
                                // Se for seller sem businessName, retornar erro
                                return Fail(error: NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Business name required for sellers"]))
                                    .eraseToAnyPublisher()
                            }
                        }
                        .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                promise(.failure(error))
                            }
                        }, receiveValue: { _ in
                            promise(.success(newUser))
                        })
                        .store(in: &self.cancellables)
                } else {
                    promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func saveUserToDatabase(user: UserModel) -> AnyPublisher<Void, Error> {
        // Não salvar a senha no Realtime Database
        var userWithoutPassword = user
        userWithoutPassword.psw = nil
        
        return databaseService.save(userWithoutPassword, path: "\(Constants.FirebasePaths.users)/\(user.id)")
    }
    
    private func fetchUserFromDatabase(userId: String) -> AnyPublisher<UserModel, Error> {
        return databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(userId)")
    }
    
    func signOut() throws {
        try firebaseManager.auth.signOut()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])))
                return
            }
            
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
        Future<Void, Error> { promise in
            // TODO: Implementar verificação de telefone com SMS
            // Por enquanto, apenas retornar sucesso
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
