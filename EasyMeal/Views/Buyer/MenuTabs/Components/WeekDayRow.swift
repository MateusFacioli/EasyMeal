//
//  WeekDayRow.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Foundation
import SwiftUI

struct WeekDayRow: View {
    let dayName: String
    let hours: String
    let location: String?
    let isActive: Bool
    let isToday: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                HStack {
                    if isToday {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 6, height: 6)
                    }
                    
                    Text(dayName)
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .regular)
                }
                .frame(width: 100, alignment: .leading)
                
                Text(hours)
                    .font(.subheadline)
                    .foregroundColor(isActive ? .primary : .gray)
                
                Spacer()
                
                if !isActive {
                    Text("Fechado")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.gray)
                        .cornerRadius(4)
                }
            }
            
            if let address = location, isActive {
                HStack {
                    Spacer()
                    Text(address)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 100)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isToday ? Color.blue.opacity(0.05) : Color.clear)
        .cornerRadius(8)
    }
}
