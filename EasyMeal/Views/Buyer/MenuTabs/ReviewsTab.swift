//
//  ReviewsTab.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import SwiftUI
import Combine

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
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(15)
            
            // Botão de Avaliar
            Button(action: { showWriteReview = true }) {
                HStack {
                    Image(systemName: "star.bubble.fill")
                    Text("Escrever uma avaliação")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.vertical)
            
            // Filtros de Avaliações
            HStack {
                Text("Avaliações dos clientes")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    Button("Mais recentes", action: { viewModel.sortBy = .recent })
                    Button("Melhores avaliações", action: { viewModel.sortBy = .highest })
                    Button("Piores avaliações", action: { viewModel.sortBy = .lowest })
                } label: {
                    Label(viewModel.sortBy.rawValue, systemImage: "arrow.up.arrow.down")
                        .font(.caption)
                }
            }
            
            // Lista de Avaliações
            if viewModel.isLoading {
                ProgressView("Carregando avaliações...")
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if viewModel.reviews.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Nenhuma avaliação ainda")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Seja o primeiro a avaliar!")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
                .padding()
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(viewModel.filteredAndSortedReviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(seller: seller)
        }
        .onAppear {
            viewModel.loadReviews(sellerId: seller.id)
        }
    }
    
    private func calculatePercentage(for stars: Int) -> Double {
        // TODO: Calcular porcentagem baseada nas avaliações reais
        // Por enquanto, retorna valores mockados
        let mockPercentages: [Int: Double] = [
            5: 60,
            4: 25,
            3: 10,
            2: 3,
            1: 2
        ]
        return mockPercentages[stars] ?? 0
    }
}

// MARK: - Preview
//struct ReviewsTab_Previews: PreviewProvider {
//    static var previews: some View {
//        let mockSeller = Seller(
//            id: "1",
//            userId: "1",
//            userEmail: "lanches@ze.com",
//            userName: "Zé",
//            userPhone: "11999999999",
//            businessName: "Lanches do Zé",
//            description: "Lanches",
//            isOnline: true,
//            currentLocation: nil,
//            schedules: [],
//            menuId: nil,
//            rating: 4.5,
//            totalReviews: 42,
//            isAvailableNow: true,
//            address: nil,
//            profileImageURL: nil,
//            createdAt: Date()
//        )
//        
//        ReviewsTab(seller: mockSeller)
//    }
//}
