//
//  EditBuyerProfileViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Foundation
import Combine
import FirebaseAuth

class EditBuyerProfileViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var phone = ""
    @Published var address = ""
    @Published var searchRadius: Double = 1000
    @Published var preferredPayment = "PIX"
    @Published var newSellersNotification = true
    @Published var offersNotification = true
    @Published var orderUpdatesNotification = true
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var hasChanges: Bool {
        // Verificar se houve mudanças
        return !fullName.isEmpty
    }
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadProfile() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.buyers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading buyer profile for edit: \(error)")
                }
            } receiveValue: { [weak self] (buyer: Buyer) in
                self?.fullName = buyer.userName
                self?.phone = buyer.userPhone
                self?.address = buyer.address ?? ""
                self?.searchRadius = buyer.searchRadius
                self?.newSellersNotification = buyer.notificationPreferences.newOffersNearby
                self?.offersNotification = buyer.notificationPreferences.promotions
                self?.orderUpdatesNotification = buyer.notificationPreferences.orderUpdates
            }
            .store(in: &cancellables)
    }
    
    func saveChanges(completion: @escaping () -> Void) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        let notificationPreferences = NotificationPreferences(
            favoriteSellerOnline: true,
            newOffersNearby: newSellersNotification,
            orderUpdates: orderUpdatesNotification,
            promotions: offersNotification
        )
        
        let updatedBuyer = Buyer(
            id: userId,
            userId: userId,
            userEmail: "", // Manter email original
            userName: fullName,
            userPhone: phone,
            favoriteSellerIds: [], // Manter favoritos existentes
            searchRadius: searchRadius,
            notificationPreferences: notificationPreferences,
            address: address.isEmpty ? nil : address,
            profileImageURL: nil, // Manter imagem existente
            createdAt: Date() // Manter data original
        )
        
        databaseService.save(updatedBuyer, path: "\(Constants.FirebasePaths.buyers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error saving buyer profile: \(error)")
                }
            } receiveValue: { _ in
                completion()
            }
            .store(in: &cancellables)
    }
}
