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
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = AuthService()) {
        self.authService = authService
        observeAuthState()
    }
    
    private func observeAuthState() {
        authService.$currentUser
            .receive(on: RunLoop.main)
            .sink { [weak self] firebaseUser in
                self?.isAuthenticated = firebaseUser != nil
                if let firebaseUser = firebaseUser {
                    self?.fetchUserData(userId: firebaseUser.uid)
                } else {
                    self?.user = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchUserData(userId: String) {
        // Implementar fetch do Firestore/Database
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
            } receiveValue: { _ in
                // Login bem sucedido
            }
            .store(in: &cancellables)
    }
    
    func signUp(email: String, password: String, phoneNumber: String, displayName: String, userType: UserType) {
        // Implementar registro
    }
    
    func signOut() {
        authService.signOut()
    }
    
    func resetPassword(email: String) {
        // Implementar reset de senha
    }
    
    func verifyPhoneNumber(_ phoneNumber: String) {
        // Implementar verificação de telefone
    }
}