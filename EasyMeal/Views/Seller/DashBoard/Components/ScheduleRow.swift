//
//  ScheduleRow.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI

struct ScheduleRow: View {
    let schedule: Schedule
    
    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(schedule.startTime, style: .time) - \(schedule.endTime, style: .time)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let address = schedule.location.address {
                    Text(address)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Circle()
                                .fill(schedule.isActive ? Color.green : Color.gray)
                                .frame(width: 10, height: 10)
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(10)
    }
}
