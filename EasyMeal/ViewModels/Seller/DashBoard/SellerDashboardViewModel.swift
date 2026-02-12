//
//  SellerDashboardViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import SwiftUI
import Combine
import FirebaseAuth

class SellerDashboardViewModel: ObservableObject {
    @Published var isOnline = false
    @Published var todayOrders = 0
    @Published var todayRevenue = "R$ 0,00"
    @Published var newCustomers = 0
    @Published var recentOrders: [OrderPreview] = []
    @Published var todaySchedules: [Schedule] = []
    @Published var revenueChange: String? = nil
    @Published var customersChange: String? = nil
    @Published var formattedRating = "0.0"
    
    private let databaseService: DatabaseServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.databaseService = databaseService
        self.locationService = locationService
    }
    
    func loadDashboardData() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        // Carregar dados do vendedor
        loadSellerData(userId: userId)
        
        // Carregar pedidos
        loadOrders(userId: userId)
        
        // Carregar horários
        loadSchedules(userId: userId)
    }
    
    private func loadSellerData(userId: String) {
        databaseService.fetch(path: "\(Constants.FirebasePaths.sellers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading seller data: \(error)")
                }
            } receiveValue: { [weak self] (seller: Seller) in
                self?.isOnline = seller.isOnline
                self?.formattedRating = seller.formattedRating
            }
            .store(in: &cancellables)
    }
    
    private func loadOrders(userId: String) {
        // Implementar carregamento de pedidos
        // Por enquanto, dados mockados
        self.recentOrders = [
            OrderPreview(
                id: "ORD001",
                customerName: "João Silva",
                total: 25.50,
                status: .pending,
                createdAt: Date()
            ),
            OrderPreview(
                id: "ORD002",
                customerName: "Maria Santos",
                total: 18.75,
                status: .confirmed,
                createdAt: Date().addingTimeInterval(-3600)
            ),
            OrderPreview(
                id: "ORD003",
                customerName: "Pedro Oliveira",
                total: 32.00,
                status: .ready,
                createdAt: Date().addingTimeInterval(-7200)
            )
        ]
        
        self.todayOrders = 3
        self.todayRevenue = "R$ 76,25"
        self.newCustomers = 2
    }
    
    private func loadSchedules(userId: String) {
        databaseService.fetch(path: "\(Constants.FirebasePaths.sellers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading schedules: \(error)")
                }
            } receiveValue: { [weak self] (seller: Seller) in
                let today = Calendar.current.component(.weekday, from: Date())
                self?.todaySchedules = seller.schedules.filter { $0.dayOfWeek == today && $0.isActive }
            }
            .store(in: &cancellables)
    }
    
    func updateLocation() {
        locationService.getCurrentLocation()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error updating location: \(error)")
                }
            } receiveValue: { [weak self] location in
                self?.updateSellerLocation(location)
            }
            .store(in: &cancellables)
    }
    
    private func updateSellerLocation(_ location: Location) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        let locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "address": location.address ?? "",
            "placeName": location.placeName ?? ""
        ]
        
        databaseService.update(path: "\(Constants.FirebasePaths.sellers)/\(userId)", data: ["currentLocation": locationData])
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error updating location: \(error)")
                } else {
                    print("Location updated successfully")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
