//
//  OrderTimeline.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI

struct OrderTimeline: View {
    let status: OrderStatus
    
    var body: some View {
        HStack(spacing: 0) {
            TimelineStep(
                icon: "cart",
                label: "Pedido",
                isCompleted: true,
                isCurrent: status == .pending
            )
            
            Rectangle()
                .fill(status.rawValue != "Pendente" ? Color.green : Color.gray)
                .frame(height: 2)
            
            TimelineStep(
                icon: "checkmark.circle",
                label: "Confirmado",
                isCompleted: status.rawValue != "Pendente",
                isCurrent: status == .confirmed
            )
            
            Rectangle()
                .fill(status.rawValue == "Preparando" || status.rawValue == "Pronto" || status.rawValue == "Entregue" ? Color.green : Color.gray)
                .frame(height: 2)
            
            TimelineStep(
                icon: "timer",
                label: "Preparando",
                isCompleted: status.rawValue == "Preparando" || status.rawValue == "Pronto" || status.rawValue == "Entregue",
                isCurrent: status == .preparing
            )
            
            Rectangle()
                .fill(status.rawValue == "Pronto" || status.rawValue == "Entregue" ? Color.green : Color.gray)
                .frame(height: 2)
            
            TimelineStep(
                icon: "checkmark",
                label: "Concluído",
                isCompleted: status.rawValue == "Pronto" || status.rawValue == "Entregue",
                isCurrent: status == .ready || status == .delivered
            )
        }
        .padding(.horizontal, 5)
    }
}
