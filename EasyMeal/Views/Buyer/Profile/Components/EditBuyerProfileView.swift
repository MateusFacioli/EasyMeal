//
//  EditBuyerProfileView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct EditBuyerProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = EditBuyerProfileViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informações Pessoais")) {
                    TextField("Nome Completo", text: $viewModel.fullName)
                    TextField("Telefone", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                    TextField("Endereço", text: $viewModel.address)
                }
                
                Section(header: Text("Preferências")) {
                    Picker("Raio de Busca", selection: $viewModel.searchRadius) {
                        Text("500 metros").tag(500.0)
                        Text("1 km").tag(1000.0)
                        Text("2 km").tag(2000.0)
                        Text("5 km").tag(5000.0)
                    }
                    
                    Picker("Método de Pagamento", selection: $viewModel.preferredPayment) {
                        Text("PIX").tag("PIX")
                        Text("Cartão").tag("Cartão")
                        Text("Dinheiro").tag("Dinheiro")
                    }
                }
                
                Section(header: Text("Notificações")) {
                    Toggle("Novos Comerciantes", isOn: $viewModel.newSellersNotification)
                    Toggle("Ofertas Especiais", isOn: $viewModel.offersNotification)
                    Toggle("Atualizações de Pedidos", isOn: $viewModel.orderUpdatesNotification)
                }
            }
            .navigationTitle("Editar Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Salvar") {
                    viewModel.saveChanges {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(!viewModel.hasChanges)
            )
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
}