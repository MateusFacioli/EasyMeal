//
//  FavoriteSellerCard.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct FavoriteSellerCard: View {
    let seller: Seller
    let isFavorite: Bool
    @State private var showingRemoveAlert = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Imagem
            ZStack(alignment: .topTrailing) {
                if let profileImageURL = seller.profileImageURL,
                   let url = URL(string: profileImageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "storefront.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "storefront.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // Status Online
                if seller.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(seller.businessName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: { showingRemoveAlert = true }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                }
                
                if !seller.description.isEmpty {
                    Text(seller.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                // Informações
                HStack(spacing: 15) {
                    if seller.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            
                            Text(seller.formattedRating)
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    if let distance = seller.distance {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            
                            Text(String(format: "%.1f km", distance))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                // Status de Disponibilidade
                HStack {
                    Image(systemName: seller.isAvailableNow ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(seller.isAvailableNow ? .green : .red)
                    
                    Text(seller.isAvailableNow ? "Disponível agora" : "Indisponível")
                        .font(.caption2)
                        .foregroundColor(seller.isAvailableNow ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .alert("Remover dos Favoritos", isPresented: $showingRemoveAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Remover", role: .destructive) {
                // Ação de remover será gerenciada pelo parent
            }
        } message: {
            Text("Deseja remover \(seller.businessName) dos seus favoritos?")
        }
    }
}
