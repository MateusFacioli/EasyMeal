//
//  SummaryItem.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI

struct SummaryItem: View {
    let title: String
    let value: String
    let change: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            if let change = change {
                Text(change)
                    .font(.caption2)
                    .foregroundColor(change.hasPrefix("+") ? .green : .red)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
