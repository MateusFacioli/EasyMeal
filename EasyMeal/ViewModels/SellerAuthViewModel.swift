//
//  UserTypeSelection.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import Combine

enum UserTypeSelection {
    case seller
    case buyer
    case none
}

class SellerAuthViewModel: ObservableObject {
    @Published var documentType: UserTypeSelection = .none
    @Published var documentNumber: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var phoneNumber: String = ""
    @Published var displayName: String = ""
    @Published var businessName: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var shouldNavigateToProfile = false
    
    private let authService: AuthServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var documentPlaceholder: String {
        switch documentType {
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
        
        switch documentType {
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
        switch documentType {
        case .seller:
            return isDocumentValid && isEmailValid && isPasswordValid && 
                   passwordsMatch && isPhoneValid && !displayName.isEmpty && 
                   !businessName.isEmpty
        case .buyer:
            return isDocumentValid && isEmailValid && isPasswordValid && 
                   passwordsMatch && isPhoneValid && !displayName.isEmpty
        case .none:
            return false
        }
    }
    
    init(authService: AuthServiceProtocol = AuthService(),
         databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.authService = authService
        self.databaseService = databaseService
    }
    
    func formatDocumentNumber() {
        let cleaned = documentNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        switch documentType {
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
        
        let userType: UserType = documentType == .seller ? .seller : .buyer
        let cleanedDocument = documentNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let userData: [String: Any] = [
            "id": UUID().uuidString,
            "email": email,
            "documentNumber": cleanedDocument,
            "phoneNumber": phoneNumber,
            "displayName": displayName,
            "userType": userType.rawValue,
            "isPhoneVerified": false,
            "createdAt": Date().timeIntervalSince1970,
            "businessName": businessName
        ]
        
        authService.signUp(email: email, password: password, userData: userData)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.successMessage = "Cadastro realizado com sucesso!"
                self?.shouldNavigateToProfile = true
                
                // Criar perfil específico do tipo de usuário
                self?.createUserProfile(userId: user.uid, userType: userType)
            }
            .store(in: &cancellables)
    }
    
    private func createUserProfile(userId: String, userType: UserType) {
        if userType == .seller {
            let seller = Seller(
                id: userId,
                userId: userId,
                businessName: businessName,
                description: "",
                isOnline: false,
                schedules: [],
                rating: 0.0,
                totalReviews: 0,
                isAvailableNow: false
            )
            
            databaseService.save(seller, path: "\(Constants.FirebasePaths.sellers)/\(userId)")
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error creating seller profile: \(error)")
                    }
                } receiveValue: { _ in
                    print("Seller profile created successfully")
                }
                .store(in: &cancellables)
        } else {
            let buyer = Buyer(
                userId: userId,
                searchRadius: 1000 // 1km default
            )
            
            databaseService.save(buyer, path: "\(Constants.FirebasePaths.buyers)/\(userId)")
                .receive(on: RunLoop.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error creating buyer profile: \(error)")
                    }
                } receiveValue: { _ in
                    print("Buyer profile created successfully")
                }
                .store(in: &cancellables)
        }
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