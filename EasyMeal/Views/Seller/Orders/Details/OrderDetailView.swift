//
//  OrderDetailView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct OrderDetailView: View {
    let order: Order
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Pedido #\(order.id.prefix(8))")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(order.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Status
                    HStack {
                        Text(order.status.rawValue)
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(statusColor(for: order.status))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        
                        Spacer()
                        
                        Text(order.formattedTotal)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    
                    // Informações do Cliente
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Informações do Cliente")
                            .font(.headline)
                        
                        InfoRow(icon: "person.fill", text: order.customerName)
                        InfoRow(icon: "phone.fill", text: order.customerPhone)
                        
                        if let notes = order.notes {
                            InfoRow(icon: "note.text", text: notes)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Itens do Pedido
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Itens do Pedido")
                            .font(.headline)
                        
                        ForEach(order.items) { item in
                            OrderItemRow(item: item)
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(order.formattedTotal)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Ações
                    if order.status == .pending {
                        VStack(spacing: 10) {
                            Button(action: { /* Confirmar */ }) {
                                Text("Confirmar Pedido")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: { /* Cancelar */ }) {
                                Text("Cancelar Pedido")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Fechar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func statusColor(for status: OrderStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .blue
        case .preparing: return .purple
        case .ready: return .green
        case .delivered: return .gray
        case .cancelled: return .red
        }
    }
}
