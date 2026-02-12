//
//  MenuSetupView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI
import PhotosUI

struct MenuSetupView: View {
    @StateObject private var viewModel = MenuSetupViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Produtos")) {
                    ForEach(viewModel.menuItems) { item in
                        HStack {
                            if let imageUrl = item.imageURLs.first,
                               let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color.gray
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                // Placeholder quando não há imagem
                                Color.gray
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .fontWeight(.medium)
                                Text(item.formattedPrice)
                                    .font(.caption)
                                    .foregroundColor(.green)
                                Text(item.category)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { item.isAvailable },
                                set: { _ in }
                            ))
                            .labelsHidden()
                        }
                    }
                    .onDelete(perform: viewModel.deleteMenuItem)
                }
                
                Section(header: Text("Adicionar Produto")) {
                    TextField("Nome do Produto", text: $viewModel.newItemName)
                    
                    TextField("Descrição", text: $viewModel.newItemDescription)
                    
                    TextField("Preço", text: $viewModel.newItemPrice)
                        .keyboardType(.decimalPad)
                    
                    Picker("Categoria", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Tempo de Preparo (minutos)", text: $viewModel.newItemPrepTime)
                        .keyboardType(.numberPad)
                    
                    // Upload de Fotos
                    PhotosPicker(selection: $viewModel.selectedPhotos,
                                 maxSelectionCount: 5,
                                 matching: .images) {
                        Label("Adicionar Fotos", systemImage: "photo")
                    }
                    
                    if !viewModel.loadedImages.isEmpty { // CORRIGIDO: Verificar loadedImages ao invés de selectedPhotos
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0..<viewModel.loadedImages.count, id: \.self) { index in
                                    Image(uiImage: viewModel.loadedImages[index]) // CORRIGIDO: Remover if let
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    
                    Button(action: viewModel.addMenuItem) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Adicionar Produto")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canAddMenuItem)
                }
            }
            .navigationBarTitle("Cardápio", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Salvar") {
                    viewModel.saveMenu()
                }
            )
            .onAppear {
                viewModel.loadMenu()
            }
        }
    }
}
