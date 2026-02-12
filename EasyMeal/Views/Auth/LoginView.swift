//
//  LoginView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text("Login")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // Formulário
            VStack(spacing: 20) {
                TextField("Email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                SecureField("Senha", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button("Esqueci minha senha") {
                    viewModel.showForgotPassword.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // Botão Login
            Button(action: viewModel.login) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Entrar")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(!viewModel.email.isEmpty && !viewModel.password.isEmpty ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty || viewModel.isLoading)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Link para Cadastro
            NavigationLink(destination: DocumentTypeView()) {
                Text("Não tem uma conta? Cadastre-se")
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 30)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.showForgotPassword) {
            ForgotPasswordView()
        }
    }
}
