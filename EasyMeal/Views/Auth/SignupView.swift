//
//  SignupView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI
import Combine

struct SignupView: View {
    @EnvironmentObject var sellerAuthVM: SellerAuthViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    Spacer()
                    Text(sellerAuthVM.userType == .seller ? "Cadastro Comerciante" : "Cadastro Cliente")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                
                // Formulário
                VStack(spacing: 15) {
                    // Documento
                    VStack(alignment: .leading, spacing: 5) {
                        Text(sellerAuthVM.userType == .seller ? "CNPJ" : "CPF")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField(sellerAuthVM.documentPlaceholder, text: $sellerAuthVM.documentNumber)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .onChange(of: sellerAuthVM.documentNumber) { _ in
                                sellerAuthVM.formatDocumentNumber()
                            }
                        
                        if !sellerAuthVM.documentNumber.isEmpty && !sellerAuthVM.isDocumentValid {
                            Text("Documento inválido")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("seu@email.com", text: $sellerAuthVM.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        if !sellerAuthVM.email.isEmpty && !sellerAuthVM.isEmailValid {
                            Text("Email inválido")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Nome/Razão Social
                    VStack(alignment: .leading, spacing: 5) {
                        Text(sellerAuthVM.userType == .seller ? "Razão Social" : "Nome Completo")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField(sellerAuthVM.userType == .seller ? "Nome da Empresa" : "Seu nome", text: $sellerAuthVM.name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Nome do Negócio (apenas para comerciante)
                    if sellerAuthVM.userType == .seller {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Nome Fantasia")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("Ex: Lanches do Zé", text: $sellerAuthVM.businessName)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    // Telefone
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Telefone")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("(11) 99999-9999", text: $sellerAuthVM.phoneNumber)
                            .keyboardType(.phonePad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        if !sellerAuthVM.phoneNumber.isEmpty && !sellerAuthVM.isPhoneValid {
                            Text("Telefone inválido")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Endereço (opcional)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Endereço (opcional)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Rua, número, bairro", text: $sellerAuthVM.address)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Senha
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Senha")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        SecureField("Mínimo 6 caracteres", text: $sellerAuthVM.password)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        if !sellerAuthVM.password.isEmpty && !sellerAuthVM.isPasswordValid {
                            Text("Mínimo 6 caracteres")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Confirmar Senha
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Confirmar Senha")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        SecureField("Digite a senha novamente", text: $sellerAuthVM.confirmPassword)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        if !sellerAuthVM.confirmPassword.isEmpty && !sellerAuthVM.passwordsMatch {
                            Text("Senhas não conferem")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Botão Cadastrar
                Button(action: sellerAuthVM.signUp) {
                    if sellerAuthVM.isLoading {
                        ProgressView("Carregando... signupview")
                            .tint(.white)
                    } else {
                        Text("Cadastrar")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(sellerAuthVM.isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(!sellerAuthVM.isFormValid || sellerAuthVM.isLoading)
                
                // Mensagens de erro/sucesso
                if let error = sellerAuthVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if let success = sellerAuthVM.successMessage {
                    Text(success)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        //MARK: TODO ROTA AQUI CHAMAR maintabview? é rota de entrada fica no loading infinito
        .navigationBarHidden(true)
        .background(
            NavigationLink(
                destination: MainTabView()
                    .environmentObject(authViewModel),
                isActive: $sellerAuthVM.shouldNavigateToProfile
            ) { EmptyView() }
        )
    }
}
