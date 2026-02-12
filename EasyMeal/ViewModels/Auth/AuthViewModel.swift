//
//  AuthViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseAuth
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let authService: AuthServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService(),
         databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.authService = authService
        self.databaseService = databaseService
        observeAuthState()
    }
    
    private func observeAuthState() {
        // Observar mudanças no estado de autenticação do Firebase
        authService.currentUserPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] firebaseUser in
                self?.isAuthenticated = firebaseUser != nil
                if let userId = firebaseUser?.uid {
                    self?.fetchUserData(userId: userId)
                } else {
                    self?.currentUser = nil
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchUserData(userId: String) {
        databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error fetching user data: \(error)")
                }
            } receiveValue: { [weak self] (user: UserModel) in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signIn(email: email, password: password)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        do {
            try authService.signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// Extensão para notificação do Firebase Auth
extension Notification.Name {
    static let AuthStateDidChange = Notification.Name("AuthStateDidChange")
}
