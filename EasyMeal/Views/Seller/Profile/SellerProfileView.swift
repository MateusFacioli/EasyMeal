//
//  SellerProfileView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine
import FirebaseAuth

struct SellerProfileView: View {
    @StateObject private var viewModel = SellerProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    @State private var showLocationSetup = false
    @State private var showHomeAfterLogout = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header com Foto
                VStack(spacing: 15) {
                    ZStack(alignment: .bottomTrailing) {
                        if let profileImageURL = viewModel.seller?.profileImageURL,
                           let url = URL(string: profileImageURL) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "storefront.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.blue.opacity(0.1)))
                        }
                        
                        Button(action: { showEditProfile = true }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                    
                    VStack(spacing: 5) {
                        Text(viewModel.seller?.businessName ?? authViewModel.currentUser?.name ?? "Seu Negócio")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(viewModel.seller?.userEmail ?? authViewModel.currentUser?.email ?? "email@exemplo.com")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Rating
                    if let rating = viewModel.seller?.rating, rating > 0 {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text(viewModel.seller?.formattedRating ?? "0.0")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Text("(\(viewModel.seller?.totalReviews ?? 0) avaliações)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.top)
                
                // Status Online
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: viewModel.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(viewModel.isOnline ? .green : .red)
                        
                        Text("Status do Negócio")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isOnline)
                            .labelsHidden()
                            .onChange(of: viewModel.isOnline) { newValue in
                                viewModel.updateOnlineStatus(newValue)
                            }
                    }
                    
                    if viewModel.isOnline {
                        Text("Seu negócio está visível para clientes próximos")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("Seu negócio não está visível para clientes")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                
                // Informações do Negócio
                VStack(alignment: .leading, spacing: 15) {
                    Text("Informações do Negócio")
                        .font(.headline)
                    
                    InfoCard(
                        icon: "text.alignleft",
                        title: "Descrição",
                        value: viewModel.seller?.description ?? "Adicione uma descrição",
                        action: { showEditProfile = true }
                    )
                    
                    // Updated Location info row with interactive button to change location
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            Image(systemName: "mappin.circle")
                                .foregroundColor(.blue)
                                .font(.title3)
                                .frame(width: 30)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Localização")
                                    .font(.headline)
                                if let location = viewModel.seller?.currentLocation {
                                    Text(location.address ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                    if let placeName = location.placeName, !placeName.isEmpty {
                                        Text(placeName)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    Text("Não definida")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        Button(action: { showLocationSetup = true }) {
                            Text("Alterar Localização")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .padding(.leading, 35)
                    }
                    
                    InfoCard(
                        icon: "clock",
                        title: "Horários",
                        value: viewModel.hasSchedules ? "Horários configurados" : "Não configurados",
                        action: { /* Navegar para horários */ }
                    )
                    
                    InfoCard(
                        icon: "menucard",
                        title: "Cardápio",
                        value: viewModel.hasMenu ? "Cardápio ativo" : "Não configurado",
                        action: { /* Navegar para cardápio */ }
                    )
                }
                .padding(.horizontal)
                
                // Estatísticas
                VStack(alignment: .leading, spacing: 15) {
                    Text("Estatísticas")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Vendas",
                            value: "\(viewModel.totalSales)",
                            icon: "cart.fill",
                            color: .green
                        )
                        
                        StatCard(
                            title: "Avaliações",
                            value: "\(viewModel.seller?.totalReviews ?? 0)",
                            icon: "star.fill",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Clientes",
                            value: "\(viewModel.totalCustomers)",
                            icon: "person.2.fill",
                            color: .blue
                        )
                    }
                }
                .padding(.horizontal)
                
                // Configurações
                VStack(alignment: .leading, spacing: 15) {
                    Text("Configurações")
                        .font(.headline)
                    
                    SettingsButton(
                        title: "Editar Perfil",
                        icon: "person.crop.circle",
                        color: .blue,
                        action: { showEditProfile = true }
                    )
                    
                    SettingsButton(
                        title: "Notificações",
                        icon: "bell.fill",
                        color: .orange,
                        action: { showSettings = true }
                    )
                    
                    SettingsButton(
                        title: "Pagamentos",
                        icon: "creditcard.fill",
                        color: .green,
                        action: { /* Navegar para pagamentos */ }
                    )
                    
                    SettingsButton(
                        title: "Ajuda e Suporte",
                        icon: "questionmark.circle.fill",
                        color: .purple,
                        action: { /* Navegar para ajuda */ }
                    )
                }
                .padding(.horizontal)
                
                // Botão Sair
                Button(action: { showLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Sair da Conta")
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditSellerProfileView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showLocationSetup, onDismiss: {
            // Refresh seller info after location update
            guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
            viewModel.loadSellerProfile(userId: userId)
        }) {
            LocationSetupView()
        }
        .fullScreenCover(isPresented: $showHomeAfterLogout) {
            MainHomeView()
        }
        .alert("Sair da Conta", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Sair", role: .destructive) {
                authViewModel.signOut()
                showHomeAfterLogout = true
            }
        } message: {
            Text("Tem certeza que deseja sair da sua conta?")
        }
        .onAppear {
            let userId = FirebaseManager.shared.currentUser?.uid ?? authViewModel.currentUser?.id
            guard let userId = userId else { return }
            viewModel.loadSellerProfile(userId: userId)
        }
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if !isAuthenticated {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

