//
//  TabButton.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct TabButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            TabButton(title: "Sobre", isSelected: true, action: {})
            TabButton(title: "Cardápio", isSelected: false, action: {})
            TabButton(title: "Horários", isSelected: false, action: {})
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}