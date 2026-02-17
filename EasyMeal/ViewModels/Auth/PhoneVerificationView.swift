//
//  PhoneVerificationView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 16/02/26.
//

import SwiftUI

struct PhoneVerificationView: View {
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isCodeSent = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Verificação de Telefone")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Digite seu telefone (+55...)"
                     , text: $phoneNumber)
                .keyboardType(.phonePad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .disabled(isCodeSent)
                .opacity(isCodeSent ? 0.5 : 1.0)
            
            if isCodeSent {
                TextField("Código SMS", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            if let success = successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            if isLoading {
                ProgressView()
            }
            
            if !isCodeSent {
                Button("Enviar Código SMS") {
                    sendSMSCode()
                }
                .disabled(phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
                .frame(maxWidth: .infinity)
                .padding()
                .background((!phoneNumber.isEmpty && !isLoading) ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("Verificar Código") {
                    verifyCode()
                }
                .disabled(verificationCode.trimmingCharacters(in: .whitespaces).count != 6 || isLoading)
                .frame(maxWidth: .infinity)
                .padding()
                .background((verificationCode.count == 6 && !isLoading) ? Color.green : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func sendSMSCode() {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        
        let authService = AuthService()
        authService.startPhoneVerification(phoneNumber: phoneNumber) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.isCodeSent = true
                    self.successMessage = "Código enviado! Verifique seu SMS."
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func verifyCode() {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        
        let authService = AuthService()
        authService.verifyPhoneCode(code: verificationCode, phoneNumber: phoneNumber) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.successMessage = "Telefone verificado com sucesso!"
                    // Atualizar AuthViewModel
                    self.authViewModel.currentUser = user
                    self.authViewModel.isAuthenticated = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
}

#Preview {
    PhoneVerificationView().environmentObject(AuthViewModel())
}
