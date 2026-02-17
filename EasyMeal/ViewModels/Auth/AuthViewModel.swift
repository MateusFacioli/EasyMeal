//
//  AuthViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseAuth
import Combine
import UIKit

class AuthViewModel: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let authService: AuthServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    init(authService: AuthServiceProtocol = AuthService(),
         databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.authService = authService
        self.databaseService = databaseService
//        setupAuthStateListener()
    }
    //MARK: TODO IREI IMPLEMENTAR DEPOIS O STATUS DA SESSAO
    private func setupAuthStateListener() {
        // Listener para mudanças no estado de autenticação
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let userId = user?.uid {
                    print("✅ Usuário autenticado: \(userId)")
                    self?.isAuthenticated = true
                    self?.fetchUserData(userId: userId)
                } else {
                    print("👤 Nenhum usuário autenticado")
                    self?.isAuthenticated = false
                    self?.currentUser = nil
                }
            }
        }
    }
    
    private func fetchUserData(userId: String) {
        print("📦 Buscando dados do usuário: \(userId)")
        let sellerPath = "\(Constants.FirebasePaths.users)/sellers/\(userId)"
        let buyerPath = "\(Constants.FirebasePaths.users)/buyers/\(userId)"
        
        databaseService.fetch(path: sellerPath)
            .catch { _ in
                self.databaseService.fetch(path: buyerPath)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ Erro ao buscar usuário: \(error.localizedDescription)")

                    if (error as NSError).code == 404 {
                        print("⚠️ Usuário não existe no DB, fazendo logout")

                        self?.signOut()
                    }
                }
            } receiveValue: { [weak self] (user: UserModel) in
                print("✅ Usuário carregado: \(user.name)")
                self?.currentUser = user
                self?.isAuthenticated = true
                self?.isLoading = false
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
                    print("❌ Erro no login: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] user in
                print("✅ Login bem sucedido: \(user.email)")
                self?.currentUser = user
                self?.isAuthenticated = true
                self?.fetchUserData(userId: user.id)
                NotificationCenter.default.post(name: .didLogin, object: nil)
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        do {
            try authService.signOut()
            clearState()
            print("✅ Logout realizado com sucesso")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Erro no logout: \(error)")
        }
    }
    
    func deleteAccount() {
        isLoading = true
        errorMessage = nil
        
        authService.deleteAccount()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("❌ Erro ao deletar conta: \(error)")
                } else {
                    print("✅ Conta deletada com sucesso")
                    self?.clearState()
                    // Notify UI that account deletion succeeded
                    NotificationCenter.default.post(name: .didDeleteAccount, object: nil)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    // MARK: - Limpar estado ao sair
    func clearState() {
        currentUser = nil
        isAuthenticated = false
        isLoading = false
        errorMessage = nil
    }
    
    deinit {
        if let handler = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}

extension Notification.Name {
    static let didLogin = Notification.Name("didLogin")
    static let didDeleteAccount = Notification.Name("didDeleteAccount")
}
