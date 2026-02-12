//
//  FavoritesViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Combine
import Foundation

class FavoritesViewModel: ObservableObject {
    @Published var favoriteSellers: [Seller] = []
    @Published var categories: [String] = ["Lanches", "Bebidas", "Doces", "Salgados", "Saudável"]
    @Published var isLoading = false
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadFavoriteSellers() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        isLoading = true
        
        // Primeiro carregar os IDs dos favoritos do usuário
        databaseService.fetch(path: "\(Constants.FirebasePaths.buyers)/\(userId)")
            .flatMap { [weak self] (buyer: Buyer) -> AnyPublisher<[Seller], Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "FavoritesViewModel", code: -1, userInfo: nil))
                        .eraseToAnyPublisher()
                }
                
                // Buscar cada seller favorito
                let publishers = buyer.favoriteSellerIds.map { sellerId in
                    self.databaseService.fetch(path: "\(Constants.FirebasePaths.sellers)/\(sellerId)")
                        .catch { _ in
                            // Se algum seller não existir mais, retornar um publisher vazio
                            return Empty<Seller, Error>().eraseToAnyPublisher()
                        }
                }
                
                return Publishers.MergeMany(publishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading favorite sellers: \(error)")
                }
            } receiveValue: { [weak self] sellers in
                self?.favoriteSellers = sellers
                self?.extractCategories(from: sellers)
            }
            .store(in: &cancellables)
    }
    
    private func extractCategories(from sellers: [Seller]) {
        var allCategories: Set<String> = []
        
        for seller in sellers {
            // Extrair categorias da descrição (simplificado)
            if seller.description.contains("lanche") || seller.businessName.contains("lanche") {
                allCategories.insert("Lanches")
            }
            if seller.description.contains("bebida") || seller.description.contains("suco") {
                allCategories.insert("Bebidas")
            }
            if seller.description.contains("doce") || seller.description.contains("sobremesa") {
                allCategories.insert("Doces")
            }
            if seller.description.contains("salgado") {
                allCategories.insert("Salgados")
            }
            if seller.description.contains("saudável") || seller.description.contains("natural") {
                allCategories.insert("Saudável")
            }
        }
        
        categories = Array(allCategories)
    }
    
    func removeFromFavorites(sellerId: String) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        // Primeiro, carregar o buyer atual
        databaseService.fetch(path: "\(Constants.FirebasePaths.buyers)/\(userId)")
            .flatMap { [weak self] (buyer: Buyer) -> AnyPublisher<Void, Error> in
                var updatedBuyer = buyer
                updatedBuyer.favoriteSellerIds.removeAll { $0 == sellerId }
                
                // Salvar buyer atualizado
                return self?.databaseService.save(updatedBuyer, path: "\(Constants.FirebasePaths.buyers)/\(userId)") ?? Empty().eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error removing from favorites: \(error)")
                }
            } receiveValue: { [weak self] _ in
                // Remover localmente
                self?.favoriteSellers.removeAll { $0.id == sellerId }
            }
            .store(in: &cancellables)
    }
}
