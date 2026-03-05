//
//  AuthService.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) -> AnyPublisher<UserModel, Error>
    func signUp(user: UserModel, password: String, businessName: String?) -> AnyPublisher<UserModel, Error>
    func signOut() throws
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func deleteAccount() -> AnyPublisher<Void, Error>
    func startPhoneVerification(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void)
    func verifyPhoneCode(code: String, phoneNumber: String, completion: @escaping (Result<UserModel, Error>) -> Void)
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
    
    // MARK: - Sign In with Email/Password
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
                    print("✅ Auth success, fetching user data for: \(firebaseUser.uid)")
                    
                    // Buscar dados do usuário no Realtime Database
                    self.fetchUserFromDatabase(userId: firebaseUser.uid)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                print("❌ Erro ao buscar usuário: \(error)")
                                // Se não encontrar no DB, fazer logout
                                try? self.firebaseManager.auth.signOut()
                                promise(.failure(error))
                            }
                        }, receiveValue: { userModel in
                            print("✅ Usuário encontrado: \(userModel.email)")
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
                    
                    // Atualizar display name no Auth
                    let changeRequest = firebaseUser.createProfileChangeRequest()
                    changeRequest.displayName = user.name
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("⚠️ Erro ao atualizar display name: \(error)")
                        }
                    }
                    
                    // Determinar o caminho baseado no tipo
                    let userTypePath = newUser.userType == .seller ? "sellers" : "buyers"
                    let userPath = "\(Constants.FirebasePaths.users)/\(userTypePath)/\(newUser.id)"
                    
                    // Salvar usuário no caminho correto: users/sellers/id ou users/buyers/id
                    self.saveUserToDatabase(user: newUser, path: userPath)
                        .flatMap { _ -> AnyPublisher<Void, Error> in
                            // Se for seller, criar dados adicionais se necessário
                            if newUser.userType == .seller {
                                // Você pode salvar dados extras do seller aqui se quiser
                                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                            }
                            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                        }
                        .sink(receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                // Se falhar, deletar o usuário do Auth
                                firebaseUser.delete { _ in
                                    promise(.failure(error))
                                }
                            } else {
                                promise(.success(newUser))
                            }
                        }, receiveValue: { _ in
                            print("✅ Usuário criado com sucesso!")
                            print("📧 Email: \(newUser.email)")
                            print("🆔 UID: \(newUser.id)")
                            print("📁 Perfil salvo em: \(userPath)")
                        })
                        .store(in: &self.cancellables)
                } else {
                    promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Save User to Database
    private func saveUserToDatabase(user: UserModel, path: String) -> AnyPublisher<Void, Error> {
        var userData: [String: Any] = [
            "id": user.id,
            "userId": user.id,
            "email": user.email,
            "name": user.name,
            "cpf_cnpj": user.cpf_cnpj,
            "phone": user.phone,
            "userType": user.userType.rawValue,
            "isPhoneVerified": user.isPhoneVerified,
            "createdAt": user.createdAt.timeIntervalSince1970
        ]
        
        if let address = user.address {
            userData["address"] = address
        }
        
        if let profileImageURL = user.profileImageURL {
            userData["profileImageURL"] = profileImageURL
        }
        
        if let fcmToken = user.fcmToken {
            userData["fcmToken"] = fcmToken
        }
        
        if user.userType == .seller {
            userData["businessName"] = user.name
        }
        
        return databaseService.update(path: path, data: userData)
    }
    
    // MARK: - Fetch User from Database
    private func fetchUserFromDatabase(userId: String) -> AnyPublisher<UserModel, Error> {
        let sellerPath = "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(userId)"
        let buyerPath = "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.buyers)/\(userId)"
        
        return databaseService.fetch(path: sellerPath)
            .catch { _ in
                self.databaseService.fetch(path: buyerPath)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Sign Out
    func signOut() throws {
        try firebaseManager.auth.signOut()
    }
    
    // MARK: - Reset Password
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
    
    // MARK: - Delete Account - auth not yet
    func deleteAccount() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { [weak self] promise in
            guard let self = self, let user = self.firebaseManager.auth.currentUser else {
                promise(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Usuário não autenticado"])))
                return
            }
            
            let userId = user.uid
            print("🗑️ Iniciando exclusão da conta: \(userId)")
            self.fetchUserFromDatabase(userId: userId)
                .flatMap { user -> AnyPublisher<Void, Error> in
                    print("✅ Usuário encontrado no DB, deletando dados...")
                    // Criar array de publishers para deletar tudo
                    var deleteOperations: [AnyPublisher<Void, Error>] = []
                    
                    // 1. Deletar dados específicos do tipo
                    if user.userType == .seller {
                        deleteOperations.append(contentsOf: self.deleteSellerData(userId: userId))
                    } else {
                        deleteOperations.append(self.safeDelete(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.buyers)/\(userId)")
                        )
                    }
                    
                    // 2. Deletar pedidos (se existirem)
                    deleteOperations.append(
                        self.safeDelete(path: "\(Constants.FirebasePaths.orders)/\(userId)")
                    )
                    
                    // 3. Deletar avaliações feitas pelo usuário
                    deleteOperations.append(self.deleteUserReviews(userId: userId))
                    // Executar todas as deleções do DB em paralelo
                    return Publishers.MergeMany(deleteOperations)
                        .collect()
                        .map { _ in
                            print("✅ Todos os dados do DB foram deletados")
                            return ()
                        }
                        .eraseToAnyPublisher()
                }
                // remove auth
                .catch { error -> AnyPublisher<Void, Error> in
                    print("⚠️ Erro ao deletar dados do DB: \(error)")
                    print("➡️ Continuando para deletar do Authentication mesmo assim...")
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                .flatMap { _ -> AnyPublisher<Void, Error> in
                    print("🗑️ Deletando usuário do Authentication...")
                    // Deletar do Firebase Authentication
                    return Future<Void, Error> { promise in
                        user.delete { error in
                            if let error = error {
                                print("❌ Erro ao deletar do Authentication: \(error)")
                                promise(.failure(error))
                            } else {
                                print("✅ Usuário deletado do Authentication com sucesso!")
                                promise(.success(()))
                            }
                        }
                    }
                    .eraseToAnyPublisher()
                }
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("❌ Falha na exclusão da conta: \(error)")
                        promise(.failure(error))
                    case .finished:
                        print("✅ Conta excluída completamente com sucesso!")
                        promise(.success(()))
                    }
                }, receiveValue: { _ in })
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    func startPhoneVerification(phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                completion(.failure(error))
            } else if let verificationID = verificationID {
                // Salvar verificationID no UserDefaults
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                completion(.success(verificationID))
            }
        }
    }
    //MARK: VERIFY seller and buyer
    func verifyPhoneCode(code: String, phoneNumber: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID de verificação não encontrado"])))
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )
        
        firebaseManager.auth.signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let firebaseUser = result?.user {
                // Verificar se usuário já existe ou criar novo
                self.fetchUserFromDatabase(userId: firebaseUser.uid)
                    .sink(receiveCompletion: { _ in
                        // Se não existir, criar novo usuário
                        let newUser = UserModel(
                            id: firebaseUser.uid,
                            email: firebaseUser.email ?? "",
                            name: firebaseUser.displayName ?? "Usuário",
                            cpf_cnpj: "",
                            phone: phoneNumber,
                            address: nil,
                            userType: .buyer, // Default
                            isPhoneVerified: true,
                            profileImageURL: firebaseUser.photoURL?.absoluteString,
                            createdAt: Date()
                        )
                        
                        // Salvar no banco
                        let userTypePath = "buyers"
                        let path = "\(Constants.FirebasePaths.users)/\(userTypePath)/\(newUser.id)"
                        
                        self.saveUserToDatabase(user: newUser, path: path)
                            .sink(receiveCompletion: { saveCompletion in
                                if case .failure(let saveError) = saveCompletion {
                                    completion(.failure(saveError))
                                } else {
                                    completion(.success(newUser))
                                }
                            }, receiveValue: { _ in })
                            .store(in: &self.cancellables)
                        
                    }, receiveValue: { userModel in
                        completion(.success(userModel))
                    })
                    .store(in: &self.cancellables)
            }
        }
    }
}

    // MARK: - Helper Methods
private extension AuthService {
    func safeDelete(path: String) -> AnyPublisher<Void, Error> {
        return databaseService.delete(path: path)
            .catch { _ -> AnyPublisher<Void, Error> in
                Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func getDeleteOperations(for user: UserModel, userId: String) -> [AnyPublisher<Void, Error>] {
        var operations: [AnyPublisher<Void, Error>] = []
        
        // Deletar pedidos
        operations.append(safeDelete(path: "\(Constants.FirebasePaths.orders)/\(userId)"))
        
        if user.userType == .seller {
            // Deletar seller e cardápio
            operations.append(contentsOf: deleteSellerData(userId: userId))
        } else {
            // Deletar buyer
            operations.append(safeDelete(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.buyers)/\(userId)"))
        }
        
        // Deletar avaliações
        operations.append(deleteUserReviews(userId: userId))
        
        return operations
    }
    
    func deleteSellerData(userId: String) -> [AnyPublisher<Void, Error>] {
        var operations: [AnyPublisher<Void, Error>] = []
        
        let sellerPublisher = databaseService.fetch(path: "\(Constants.FirebasePaths.sellers)/\(userId)")
            .flatMap { (seller: Seller) -> AnyPublisher<Void, Error> in
                var sellerOps: [AnyPublisher<Void, Error>] = []
                
                if let menuId = seller.menuId {
                    sellerOps.append(self.safeDelete(path: "\(Constants.FirebasePaths.menus)/\(menuId)"))
                }
                
                sellerOps.append(self.safeDelete(path: "\(Constants.FirebasePaths.sellers)/\(userId)"))
                
                return Publishers.MergeMany(sellerOps)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .catch { _ -> AnyPublisher<Void, Error> in
                self.safeDelete(path: "\(Constants.FirebasePaths.sellers)/\(userId)")
            }
            .eraseToAnyPublisher()
        
        operations.append(sellerPublisher)
        return operations
    }
    
    func deleteUserReviews(userId: String) -> AnyPublisher<Void, Error> {
        return databaseService.fetchAll(path: Constants.FirebasePaths.reviews)
            .flatMap { (reviews: [Review]) -> AnyPublisher<Void, Error> in
                var reviewDeletes: [AnyPublisher<Void, Error>] = []
                
                // Filtrar avaliações onde o userId é o autor
                let userReviews = reviews.filter { $0.userId == userId }
                
                for review in userReviews {
                    let path = "\(Constants.FirebasePaths.reviews)/\(review.sellerId)/\(review.id)"
                    reviewDeletes.append(self.safeDelete(path: path))
                }
                
                if reviewDeletes.isEmpty {
                    return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                return Publishers.MergeMany(reviewDeletes)
                    .collect()
                    .map { _ in () }
                    .eraseToAnyPublisher()
            }
            .catch { _ -> AnyPublisher<Void, Error> in
                Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

