//
//  View+Extensions.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension Double {
    var formattedAsCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: self)) ?? "R$ \(self)"
    }
}

extension String {
    var formattedPhoneNumber: String {
        let numbers = self.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if numbers.count == 11 {
            return "(\(numbers.prefix(2))) \(numbers.dropFirst(2).prefix(5))-\(numbers.dropFirst(7))"
        } else if numbers.count == 10 {
            return "(\(numbers.prefix(2))) \(numbers.dropFirst(2).prefix(4))-\(numbers.dropFirst(6))"
        }
        return self
    }
}
