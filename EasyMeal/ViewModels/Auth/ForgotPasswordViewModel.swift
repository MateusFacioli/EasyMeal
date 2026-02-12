//
//  ForgotPasswordViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import SwiftUI
import Combine

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var isEmailValid: Bool {
        Validators.isValidEmail(email)
    }
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func sendResetLink() {
        guard isEmailValid else {
            errorMessage = "Por favor, insira um email válido."
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        authService.resetPassword(email: email)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.successMessage = "Email de recuperação enviado com sucesso! Verifique sua caixa de entrada."
            }
            .store(in: &cancellables) // CORRIGIDO: adicionado & e usando a propriedade
    }
}
