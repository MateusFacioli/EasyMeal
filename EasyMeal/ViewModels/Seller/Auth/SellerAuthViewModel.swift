//
//  SellerAuthViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import Combine

class SellerAuthViewModel: ObservableObject {
    @Published var userType: UserTypeSelection = .none
    @Published var documentNumber: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var phoneNumber: String = ""
    @Published var name: String = ""
    @Published var address: String = ""
    @Published var businessName: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var shouldNavigateToProfile = false
    
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var documentPlaceholder: String {
        switch userType {
        case .seller:
            return "00.000.000/0001-00"
        case .buyer:
            return "000.000.000-00"
        case .none:
            return "CPF ou CNPJ"
        }
    }
    
    var isDocumentValid: Bool {
        guard !documentNumber.isEmpty else { return false }
        let cleanedDocument = documentNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        switch userType {
        case .seller:
            return Validators.isValidCNPJ(cleanedDocument)
        case .buyer:
            return Validators.isValidCPF(cleanedDocument)
        case .none:
            return false
        }
    }
    
    var isEmailValid: Bool {
        Validators.isValidEmail(email)
    }
    
    var isPasswordValid: Bool {
        password.count >= Constants.Validation.minPasswordLength
    }
    
    var passwordsMatch: Bool {
        password == confirmPassword
    }
    
    var isPhoneValid: Bool {
        Validators.isValidPhone(phoneNumber)
    }
    
    var isFormValid: Bool {
        guard userType != .none else { return false }
        
        let commonValidations = isDocumentValid &&
                               isEmailValid &&
                               isPasswordValid &&
                               passwordsMatch &&
                               isPhoneValid &&
                               !name.isEmpty
        
        if userType == .seller {
            return commonValidations && !businessName.isEmpty
        } else {
            return commonValidations
        }
    }
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func formatDocumentNumber() {
        let cleaned = documentNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        switch userType {
        case .seller:
            documentNumber = Validators.formatCNPJ(cleaned)
        case .buyer:
            documentNumber = Validators.formatCPF(cleaned)
        case .none:
            break
        }
    }
    
    func signUp() {
            guard isFormValid else {
                errorMessage = "Por favor, preencha todos os campos corretamente."
                return
            }
            
            isLoading = true
            errorMessage = nil
            
            let cleanedDocument = documentNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            let user = UserModel(
                email: email,
                psw: password,
                name: userType == .seller ? businessName : name,
                cpf_cnpj: cleanedDocument,
                phone: phoneNumber,
                address: address.isEmpty ? nil : address,
                userType: userType == .seller ? .seller : .buyer,
                isPhoneVerified: false,
                profileImageURL: nil,
                createdAt: Date()
            )
            
            // Passar businessName apenas para sellers
            let businessNameForSeller = userType == .seller ? businessName : nil
            
            authService.signUp(user: user, password: password, businessName: businessNameForSeller)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                } receiveValue: { [weak self] user in
                    self?.successMessage = "Cadastro realizado com sucesso!"
                    self?.shouldNavigateToProfile = true
                    
                    // Salvar tipo de usuário localmente
                    UserDefaults.standard.set(user.userType.rawValue, forKey: Constants.UserDefaultsKeys.userType)
                }
                .store(in: &cancellables)
        }
    
    func resetPassword() {
        guard isEmailValid else {
            errorMessage = "Por favor, insira um email válido."
            return
        }
        
        isLoading = true
        
        authService.resetPassword(email: email)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.successMessage = "Email de recuperação enviado com sucesso!"
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
