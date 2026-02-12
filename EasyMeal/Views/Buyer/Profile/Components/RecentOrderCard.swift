//
//  RecentOrderCard.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI

struct RecentOrderCard: View {
    let order: Order
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(order.sellerName ?? "Comerciante")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(order.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(order.formattedTotal)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(order.status.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor(for: order.status))
                    .foregroundColor(.white)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
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
