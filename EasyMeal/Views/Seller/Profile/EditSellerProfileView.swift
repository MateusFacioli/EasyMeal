//
//  EditSellerProfileView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import PhotosUI

struct EditSellerProfileView: View {
    @StateObject private var viewModel = EditSellerProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Foto do Perfil")) {
                    HStack {
                        Spacer()
                        VStack {
                            if let profileImage = viewModel.profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "storefront.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.blue)
                            }
                            
                            PhotosPicker(selection: $selectedPhoto,
                                        matching: .images,
                                        photoLibrary: .shared()) {
                                Text("Escolher Foto")
                                    .font(.caption)
                            }
                            .onChange(of: selectedPhoto) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        viewModel.profileImage = image
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Informações do Negócio")) {
                    TextField("Nome do Negócio", text: $viewModel.businessName)
                    TextField("Descrição", text: $viewModel.description)
                    TextField("Telefone", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                    TextField("Endereço", text: $viewModel.address)
                }
                
                Section {
                    Button("Atualizar Localização Atual") {
                        viewModel.updateLocation { location in
                            // Aqui você pode atualizar a localização se necessário
                            print("Nova localização: \(location)")
                        }
                    }
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
                .disabled(!viewModel.hasChanges || viewModel.isLoading)
            )
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .alert("Erro", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .alert("Sucesso", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") {
                    viewModel.successMessage = nil
                }
            } message: {
                if let success = viewModel.successMessage {
                    Text(success)
                }
            }
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
}
