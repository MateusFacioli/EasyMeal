//
//  TimelineStep.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


struct TimelineStep: View {
    let icon: String
    let label: String
    let isCompleted: Bool
    let isCurrent: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isCompleted ? .green : .gray)
                .frame(width: 20, height: 20)
                .background(isCurrent ? Color.green.opacity(0.2) : Color.clear)
                .clipShape(Circle())
            
            Text(label)
                .font(.caption2)
                .foregroundColor(isCompleted ? .green : .gray)
        }
        .frame(width: 60)
    }
}
