//
//  ReviewsTab.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI

struct ReviewsTab: View {
    let seller: Seller
    @StateObject private var viewModel = ReviewsTabViewModel()
    @State private var showWriteReview = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Resumo das Avaliações
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(String(format: "%.1f", seller.rating))
                        .font(.system(size: 48))
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(seller.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Text("\(seller.totalReviews) avaliações")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 10) {
                    RatingDistributionRow(starCount: 5, percentage: calculatePercentage(for: 5))
                    RatingDistributionRow(starCount: 4, percentage: calculatePercentage(for: 4))
                    RatingDistributionRow(starCount: 3, percentage: calculatePercentage(for: 3))
                    RatingDistributionRow(starCount: 2, percentage: calculatePercentage(for: 2))
                    RatingDistributionRow(starCount: 1, percentage: calculatePercentage(for: 1))
                }
                .frame(maxWidth: .infinity)
            }