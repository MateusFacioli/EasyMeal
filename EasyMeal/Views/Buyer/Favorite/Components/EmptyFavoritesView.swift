//
//  EmptyFavoritesView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI

struct EmptyFavoritesView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            if searchText.isEmpty {
                VStack(spacing: 10) {
                    Text("Nenhum favorito ainda")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Adicione comerciantes aos favoritos para vê-los aqui")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                Text("Nenhum resultado para '\(searchText)'")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            NavigationLink(destination: BuyerHomeView()) {
                Text("Descobrir Comerciantes")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxHeight: .infinity)
    }
}
