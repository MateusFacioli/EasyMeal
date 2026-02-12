//
//  MenuItemDetailView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct MenuItemDetailView: View {
    let item: MenuItem
    let seller: Seller
    @Environment(\.presentationMode) var presentationMode
    @State private var quantity = 1
    @State private var specialInstructions = ""
    @State private var showAddToCartConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Imagem do Produto
                    if let firstImageURL = item.imageURLs.first,
                       let url = URL(string: firstImageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(0)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 250)
                            .frame(maxWidth: .infinity)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Informações do Produto
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(item.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                if !item.isAvailable {
                                    Text("Indisponível")
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.red.opacity(0.1))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack(spacing: 12) {
                                Label {
                                    Text(item.category)
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: "folder")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                
                                Label {
                                    Text("\(item.preparationTime) min")
                                        .font(.caption)
                                } icon: {
                                    Image(systemName: "clock")
                                        .font(.caption2)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.1))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                            }
                        }
                        
                        Divider()
                        
                        // Descrição
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Descrição")
                                .font(.headline)
                            
                            Text(item.description)
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                        
                        // Ingredientes
                        if !item.ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ingredientes")
                                    .font(.headline)
                                
                                Text(item.ingredients.joined(separator: ", "))
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            
                            Divider()
                        }
                        
                        // Observações
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Observações")
                                .font(.headline)
                            
                            TextField("Alguma observação? Ex: sem cebola, ponto da carne...", text: $specialInstructions)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        Divider()
                        
                        // Quantidade e Preço
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Quantidade")
                                    .font(.headline)
                                
                                HStack(spacing: 20) {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                    
                                    Text("\(quantity)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .frame(width: 40)
                                    
                                    Button(action: { quantity += 1 }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total")
                                    .font(.headline)
                                
                                Text((item.price * Double(quantity)).formattedAsCurrency)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Adicionar") {
                    showAddToCartConfirmation = true
                }
                .disabled(!item.isAvailable)
            )
            .alert("Item Adicionado", isPresented: $showAddToCartConfirmation) {
                Button("Ver Carrinho") {
                    // Navegar para o carrinho
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Continuar Comprando", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("\(item.name) foi adicionado ao seu carrinho.")
            }
        }
    }
}
