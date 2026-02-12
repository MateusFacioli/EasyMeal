//
//  SellerProfileSetupView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import SwiftUI
import FirebaseAuth

struct SellerProfileSetupView: View {
    @StateObject private var viewModel = SellerProfileViewModel()
    @State private var showLocationSetup = false
    @State private var showScheduleSetup = false
    @State private var showMenuSetup = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                Text("Configuração do Perfil")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Status Online/Offline
                VStack(spacing: 15) {
                    Text("Status do Negócio")
                        .font(.headline)
                    
                    Toggle(isOn: $viewModel.isOnline) {
                        HStack {
                            Image(systemName: viewModel.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(viewModel.isOnline ? .green : .red)
                            Text(viewModel.isOnline ? "Online" : "Offline")
                                .fontWeight(.medium)
                        }
                    }
                    .onChange(of: viewModel.isOnline) { newValue in
                        viewModel.updateOnlineStatus(newValue)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Configurações Rápidas
                VStack(spacing: 15) {
                    Text("Configurações")
                        .font(.headline)
                    
                    // Localização
                    Button(action: { showLocationSetup = true }) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Localização")
                                    .fontWeight(.medium)
                                Text("Defina onde você atende")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(10)
                    }
                    
                    // Horários
                    Button(action: { showScheduleSetup = true }) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Horários")
                                    .fontWeight(.medium)
                                Text("Defina quando você atende")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.orange.opacity(0.05))
                        .cornerRadius(10)
                    }
                    
                    // Cardápio
                    Button(action: { showMenuSetup = true }) {
                        HStack {
                            Image(systemName: "menucard.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Cardápio")
                                    .fontWeight(.medium)
                                Text("Adicione seus produtos")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                
                // Descrição do Negócio
                VStack(alignment: .leading, spacing: 10) {
                    Text("Descrição do Negócio")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.businessDescription)
                        .frame(height: 100)
                        .padding(4)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    Button("Salvar Descrição") {
                        viewModel.updateBusinessDescription(viewModel.businessDescription)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Localização Atual
                if let location = viewModel.currentLocation {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Localização Atual")
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            VStack(alignment: .leading) {
                                Text(location.placeName ?? "Local não identificado")
                                    .fontWeight(.medium)
                                if let address = location.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.05))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                
                // Botão Atualizar Localização
                Button(action: viewModel.updateCurrentLocation) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Atualizar Localização")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .sheet(isPresented: $showLocationSetup) {
            LocationSetupView()
        }
        .sheet(isPresented: $showScheduleSetup) {
            ScheduleSetupView()
        }
        .sheet(isPresented: $showMenuSetup) {
            MenuSetupView()
        }
        .onAppear {
            // Carregar perfil do vendedor
            if let userId = FirebaseManager.shared.currentUser?.uid {
                viewModel.loadSellerProfile(userId: userId)
            }
        }
    }
}
