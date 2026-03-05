//
//  OrderHistoryDetailView.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct OrderHistoryDetailView: View {
    let order: OrderModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showRateSeller = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 10) {
                        Text(order.sellerName ?? "Comerciante")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Pedido #\(order.id.prefix(8))")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text(order.createdAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top)
                    
                    // Status
                    VStack(spacing: 10) {
                        Text(order.status.rawValue)
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(statusColor(for: order.status))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        
                        if order.status == .delivered {
                            Text("Entregue em \(order.createdAt, style: .date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
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
                    
                    // Informações do Pedido
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Informações do Pedido")
                            .font(.headline)
                        
                        InfoDetailRow(title: "Método de Pagamento", value: order.paymentMethod ?? "Não informado")
                        InfoDetailRow(title: "Observações", value: order.notes ?? "Nenhuma")
                        
                        if let estimatedTime = order.estimatedDeliveryTime {
                            InfoDetailRow(title: "Tempo Estimado", value: "\(estimatedTime) min")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Ações
                    if order.status == .delivered {
                        Button(action: { showRateSeller = true }) {
                            Text("Avaliar Compra")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    if order.status == .ready || order.status == .preparing {
                        Button(action: { /* Ver localização do seller */ }) {
                            Text("Ver Localização")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
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
            .sheet(isPresented: $showRateSeller) {
                RateOrderView(order: order)
            }
        }
    }
}
