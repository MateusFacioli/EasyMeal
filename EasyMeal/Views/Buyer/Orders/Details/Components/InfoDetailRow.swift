//
//  InfoDetailRow.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine

struct InfoDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}
