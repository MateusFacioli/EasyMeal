//
//  OrderCard.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct OrderCard: View {
    let order: OrderModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pedido #\(order.id.prefix(8))")
                        .font(.headline)
                    
                    Text(order.customerName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(order.formattedTotal)
                        .font(.headline)
                    
                    Text(order.createdAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Status
            HStack {
                Text(order.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: order.status))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                
                Spacer()
                
                Text("\(order.items.count) itens")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Itens
            if let firstItem = order.items.first {
                Text("• \(firstItem.name)")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                if order.items.count > 1 {
                    Text("+ \(order.items.count - 1) mais")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
            
            // Método de Pagamento
            if let paymentMethod = order.paymentMethod {
                HStack {
                    Image(systemName: paymentIcon(for: paymentMethod))
                        .font(.caption2)
                    Text(paymentMethod)
                        .font(.caption)
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
    
    private func paymentIcon(for method: String) -> String {
        switch method.lowercased() {
        case "pix": return "qrcode"
        case "cartão": return "creditcard"
        case "dinheiro": return "banknote"
        default: return "creditcard"
        }
    }
}
