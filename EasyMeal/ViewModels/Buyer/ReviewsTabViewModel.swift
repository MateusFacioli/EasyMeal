//
//  ReviewsTabViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Combine
import Foundation

class ReviewsTabViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var isLoading = false
    @Published var sortBy: SortOption = .recent
    
    enum SortOption: String, CaseIterable {
        case recent = "Mais recentes"
        case highest = "Melhores avaliações"
        case lowest = "Piores avaliações"
    }
    
    var filteredAndSortedReviews: [Review] {
        switch sortBy {
        case .recent:
            return reviews.sorted { $0.date > $1.date }
        case .highest:
            return reviews.sorted { $0.rating > $1.rating }
        case .lowest:
            return reviews.sorted { $0.rating < $1.rating }
        }
    }
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadReviews(sellerId: String) {
        isLoading = true
        
        // TODO: Implementar carregamento real do Firebase
        // Por enquanto, dados mockados
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.reviews = [
                Review(
                    id: "1",
                    sellerId: sellerId,
                    userId: "user1",
                    userName: "João Silva",
                    rating: 5,
                    comment: "Excelente atendimento! Comida deliciosa e entrega rápida. Recomendo muito!",
                    imageURLs: [],
                    date: Date().addingTimeInterval(-86400),
                    helpfulCount: 12,
                    sellerReply: SellerReply(
                        comment: "Muito obrigado pela avaliação, João! Ficamos felizes em atender você.",
                        date: Date().addingTimeInterval(-43200)
                    )
                ),
                Review(
                    id: "2",
                    sellerId: sellerId,
                    userId: "user2",
                    userName: "Maria Santos",
                    rating: 4,
                    comment: "Ótimo lanche, mas o tempo de espera foi um pouco longo. De resto, tudo perfeito!",
                    imageURLs: [],
                    date: Date().addingTimeInterval(-172800),
                    helpfulCount: 5,
                    sellerReply: nil
                ),
                Review(
                    id: "3",
                    sellerId: sellerId,
                    userId: "user3",
                    userName: "Pedro Oliveira",
                    rating: 5,
                    comment: "Melhor hambúrguer da região! Já pedi várias vezes e nunca decepciona.",
                    imageURLs: [],
                    date: Date().addingTimeInterval(-259200),
                    helpfulCount: 8,
                    sellerReply: nil
                )
            ]
            self.isLoading = false
        }
        
        // TODO: Implementar carregamento real
        // databaseService.fetch(path: "\(Constants.FirebasePaths.reviews)/\(sellerId)")
    }
}
