//
//  SellerDashboardView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct SellerDashboardView: View {
    @StateObject private var viewModel = SellerDashboardViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header com status
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Gerencie seu negócio")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Status Online/Offline
                        Toggle("", isOn: $viewModel.isOnline)
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .labelsHidden()
                            .scaleEffect(0.8)
                    }
                    
                    // Card de Status
                    HStack(spacing: 15) {
                        StatusCard(
                            title: "Online",
                            value: viewModel.isOnline ? "Sim" : "Não",
                            icon: viewModel.isOnline ? "checkmark.circle.fill" : "xmark.circle.fill",
                            color: viewModel.isOnline ? .green : .red
                        )
                        
                        StatusCard(
                            title: "Pedidos Hoje",
                            value: "\(viewModel.todayOrders)",
                            icon: "cart.fill",
                            color: .blue
                        )
                        
                        StatusCard(
                            title: "Avaliação",
                            value: viewModel.formattedRating,
                            icon: "star.fill",
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal)
                
                // Card de Resumo
                VStack(alignment: .leading, spacing: 15) {
                    Text("Resumo do Dia")
                        .font(.headline)
                    
                    HStack {
                        SummaryItem(
                            title: "Faturamento",
                            value: viewModel.todayRevenue,
                            change: viewModel.revenueChange
                        )
                        
                        Divider()
                            .frame(height: 40)
                        
                        SummaryItem(
                            title: "Novos Clientes",
                            value: "\(viewModel.newCustomers)",
                            change: viewModel.customersChange
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(15)
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                }
                .padding(.horizontal)
                
                // Pedidos Recentes
                if !viewModel.recentOrders.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Pedidos Recentes")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink(destination: OrdersView()) {
                                Text("Ver Todos")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        ForEach(viewModel.recentOrders.prefix(3)) { order in
                            OrderRow(order: order)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Ações Rápidas
                VStack(alignment: .leading, spacing: 15) {
                    Text("Ações Rápidas")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        QuickActionButton(
                            title: "Cardápio",
                            icon: "menucard.fill",
                            color: .blue,
                            action: {
                                // Navegar para cardápio
                            }
                        )
                        
                        QuickActionButton(
                            title: "Horários",
                            icon: "clock.fill",
                            color: .orange,
                            action: {
                                // Navegar para horários
                            }
                        )
                        
                        QuickActionButton(
                            title: "Localização",
                            icon: "location.fill",
                            color: .green,
                            action: {
                                // Navegar para localização
                            }
                        )
                        
                        QuickActionButton(
                            title: "Estoque",
                            icon: "cube.box.fill",
                            color: .purple,
                            action: {
                                // Navegar para estoque
                            }
                        )
                    }
                }
                .padding(.horizontal)
                
                // Próximos Horários
                if !viewModel.todaySchedules.isEmpty {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Horários de Hoje")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: viewModel.updateLocation) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        ForEach(viewModel.todaySchedules) { schedule in
                            ScheduleRow(schedule: schedule)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadDashboardData()
        }
    }
}
