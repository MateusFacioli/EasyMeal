//
//  SellerDetailView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//
import SwiftUI
import Combine

struct SellerDetailView: View {
    let seller: Seller
    @Environment(\.presentationMode) var presentationMode
    @State private var showMenu = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header com imagem
                    ZStack(alignment: .bottom) {
                        Color.blue.opacity(0.1)
                            .frame(height: 150)
                        
                        VStack(spacing: 10) {
                            Image(systemName: "storefront.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text(seller.businessName)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    // Tabs
                    HStack {
                        TabButton(title: "Sobre", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(title: "Cardápio", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabButton(title: "Horários", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                        
                        TabButton(title: "Avaliações", isSelected: selectedTab == 3) {
                            selectedTab = 3
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    
                    // Conteúdo da Tab
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            AboutTab(seller: seller)
                        } else if selectedTab == 1 {
                            MenuTab(seller: seller)
                        } else if selectedTab == 2 {
                            ScheduleTab(seller: seller)
                        } else {
                            ReviewsTab(seller: seller)
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Fechar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
