import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = ForgotPasswordViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Recuperar Senha")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Digite seu email para receber o link de recuperação")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                // Campo de Email
                TextField("Seu email", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(!viewModel.email.isEmpty && !viewModel.isEmailValid ? Color.red : Color.clear, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                if !viewModel.email.isEmpty && !viewModel.isEmailValid {
                    Text("Email inválido")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Botão Enviar
                Button(action: viewModel.sendResetLink) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Enviar Link de Recuperação")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isEmailValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(!viewModel.isEmailValid || viewModel.isLoading)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                if let success = viewModel.successMessage {
                    VStack(spacing: 10) {
                        Text(success)
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal)
                        
                        Button("OK") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancelar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    var isEmailValid: Bool {
        Validators.isValidEmail(email)
    }
    
    private let authService: AuthServiceProtocol
    
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
            .store(in: .init())
    }
}