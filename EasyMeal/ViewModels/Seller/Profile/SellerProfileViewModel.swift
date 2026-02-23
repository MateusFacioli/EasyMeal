//
//  SellerProfileViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import Foundation
import Combine

class SellerProfileViewModel: ObservableObject {
    @Published var seller: Seller?
    @Published var isOnline = false
    @Published var totalSales = 0
    @Published var totalCustomers = 0
    @Published var isLoading = false
    @Published var businessDescription = ""
    @Published var currentLocation: Location?
    
    var hasSchedules: Bool {
        guard let seller = seller else { return false }
        return !seller.schedules.isEmpty
    }
    
    var hasMenu: Bool {
        guard let seller = seller else { return false }
        return seller.menuId != nil
    }
    
    private let databaseService: DatabaseServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.databaseService = databaseService
        self.locationService = locationService
    }
    
    func loadSellerProfile(userId: String) {
        isLoading = true
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading seller profile: \(error)")
                }
            } receiveValue: { [weak self] (seller: Seller) in
                self?.seller = seller
                self?.isOnline = seller.isOnline
                self?.businessDescription = seller.description
                self?.currentLocation = seller.currentLocation
                self?.loadStatistics(sellerId: seller.id)
            }
            .store(in: &cancellables)
    }
    
    private func loadStatistics(sellerId: String) {
        // TODO: Carregar estatísticas reais do Firebase
        // Por enquanto, dados mockados
        self.totalSales = 42
        self.totalCustomers = 15
    }
    
    func updateOnlineStatus(_ online: Bool) {
        guard let sellerId = seller?.id else { return }
        
        let updates = [
            "isOnline": online,
            "isAvailableNow": online
        ]
        
        databaseService.update(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(sellerId)", data: updates)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error updating online status: \(error)")
                }
            } receiveValue: { [weak self] in
                self?.isOnline = online
                self?.seller?.isOnline = online
                self?.seller?.isAvailableNow = online
            }
            .store(in: &cancellables)
    }
    
    func updateBusinessDescription(_ description: String) {
        guard let sellerId = seller?.id else { return }
        
        databaseService.update(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(sellerId)", data: ["description": description])
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error updating description: \(error)")
                }
            } receiveValue: { [weak self] in
                self?.businessDescription = description
                self?.seller?.description = description
            }
            .store(in: &cancellables)
    }
    
    func updateCurrentLocation() {
        locationService.getCurrentLocation()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error getting location: \(error)")
                }
            } receiveValue: { [weak self] location in
                self?.currentLocation = location
                self?.saveLocationAndSetOnline(location)
            }
            .store(in: &cancellables)
    }
    
    private func saveLocationAndSetOnline(_ location: Location) {
        guard let sellerId = seller?.id else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "address": location.address ?? "",
            "placeName": location.placeName ?? ""
        ]
        
        // Step 1: Save location
        databaseService.update(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(sellerId)", data: ["currentLocation": locationData])
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "SelfDeallocated", code: -1, userInfo: nil))
                        .eraseToAnyPublisher()
                }
                // Step 2: Update online status to true in Firebase
                let onlineData: [String: Any] = [
                    "isOnline": true,
                    "isAvailableNow": true
                ]
                return self.databaseService.update(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(sellerId)", data: onlineData)
            }
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error saving location or updating online status: \(error)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] in
                // Step 3: Update local state and notify
                self?.isOnline = true
                self?.seller?.isOnline = true
                self?.seller?.isAvailableNow = true
                
                // Send push notification to buyers that seller is online
                NotificationCenter.default.post(name: .sellerDidBecomeOnline, object: self?.seller)
            }
            .store(in: &cancellables)
    }
}
extension Notification.Name {
    static let sellerDidBecomeOnline = Notification.Name("sellerDidBecomeOnline")
}

