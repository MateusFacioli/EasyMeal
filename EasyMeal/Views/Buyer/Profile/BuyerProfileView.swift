//
//  BuyerProfileView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI
import FirebaseAuth
import Combine

struct BuyerProfileView: View {
    @StateObject private var viewModel = BuyerProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showLogoutAlert = false
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header com Foto
                VStack(spacing: 15) {
                    ZStack(alignment: .bottomTrailing) {
                        if let profileImageURL = viewModel.buyer?.profileImageURL,
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
                            Image(systemName: "person.circle.fill")
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
                        Text(viewModel.buyer?.userName ?? "Cliente")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(viewModel.buyer?.userEmail ?? "email@exemplo.com")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top)
                
                // Estatísticas
                VStack(alignment: .leading, spacing: 15) {
                    Text("Minhas Estatísticas")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        StatCard(
                            title: "Pedidos",
                            value: "\(viewModel.totalOrders)",
                            icon: "cart.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Favoritos",
                            value: "\(viewModel.totalFavorites)",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        StatCard(
                            title: "Avaliações",
                            value: "\(viewModel.totalRatings)",
                            icon: "star.fill",
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal)
                
                // Preferências
                VStack(alignment: .leading, spacing: 15) {
                    Text("Minhas Preferências")
                        .font(.headline)
                    
                    PreferenceCard(
                        title: "Raio de Busca",
                        value: "\(Int(viewModel.searchRadius)) metros",
                        icon: "location.fill",
                        action: { /* Editar raio */ }
                    )
                    
                    PreferenceCard(
                        title: "Notificações",
                        value: viewModel.notificationsEnabled ? "Ativadas" : "Desativadas",
                        icon: "bell.fill",
                        action: { /* Editar notificações */ }
                    )
                    
                    PreferenceCard(
                        title: "Pagamento Preferido",
                        value: viewModel.preferredPayment ?? "Não definido",
                        icon: "creditcard.fill",
                        action: { /* Editar pagamento */ }
                    )
                }
                .padding(.horizontal)
                
                // Pedidos Recentes
                if !viewModel.recentOrders.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Pedidos Recentes")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: OrdersHistoryView()) {
                                Text("Ver Todos")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        ForEach(viewModel.recentOrders.prefix(3)) { order in
                            RecentOrderCard(order: order)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Configurações da Conta
                VStack(alignment: .leading, spacing: 15) {
                    Text("Conta")
                        .font(.headline)
                    
                    AccountButton(
                        title: "Editar Perfil",
                        icon: "person.crop.circle",
                        color: .blue,
                        action: { showEditProfile = true }
                    )
                    
                    AccountButton(
                        title: "Configurações",
                        icon: "gearshape.fill",
                        color: .gray,
                        action: { showSettings = true }
                    )
                    
                    AccountButton(
                        title: "Ajuda e Suporte",
                        icon: "questionmark.circle.fill",
                        color: .purple,
                        action: { /* Navegar para ajuda */ }
                    )
                    
                    AccountButton(
                        title: "Sobre o App",
                        icon: "info.circle.fill",
                        color: .green,
                        action: { /* Mostrar sobre */ }
                    )
                }
                .padding(.horizontal)
                
                // Botões de Ação
                VStack(spacing: 10) {
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
                    
                    Button(action: { showDeleteAccountAlert = true }) {
                        Text("Excluir Conta")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
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
            EditBuyerProfileView()
        }
        .sheet(isPresented: $showSettings) {
            BuyerSettingsView()
        }
        .alert("Sair da Conta", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Sair", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Tem certeza que deseja sair da sua conta?")
        }
        .alert("Excluir Conta", isPresented: $showDeleteAccountAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Esta ação não pode ser desfeita. Todos os seus dados serão permanentemente excluídos.")
        }
        .onAppear {
            viewModel.loadBuyerProfile()
        }
    }
    
    private func deleteAccount() {
        // Implementar exclusão da conta
        print("Excluindo conta...")
    }
}
