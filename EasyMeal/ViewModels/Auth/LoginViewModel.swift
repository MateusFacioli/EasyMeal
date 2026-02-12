//
//  LoginViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showForgotPassword = false
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha todos os campos"
            return
        }
        
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
                // Login bem sucedido - navegação é gerenciada pelo AuthViewModel
            }
            .store(in: &cancellables) // CORRIGIDO: adicionado & e usando a propriedade
    }
}
