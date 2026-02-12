//
//  OrderHistoryCard.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct OrderHistoryCard: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(order.sellerName ?? "Comerciante")
                        .font(.headline)
                    
                    Text("Pedido #\(order.id.prefix(8))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(order.formattedTotal)
                        .font(.headline)
                    
                    Text(order.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Status e Timeline
            VStack(spacing: 8) {
                HStack {
                    Text(order.status.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: order.status))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    if order.status == .delivered {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                // Timeline simplificado
                OrderTimeline(status: order.status)
            }
            
            // Resumo dos Itens
            if let firstItem = order.items.first {
                HStack {
                    Text("• \(firstItem.name)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if order.items.count > 1 {
                        Text("+ \(order.items.count - 1) mais")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if order.status == .delivered {
                        Button("Avaliar") {
                            // Navegar para avaliação
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
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