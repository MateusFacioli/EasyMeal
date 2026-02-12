//
//  BuyerHomeViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Combine
import Foundation

class BuyerHomeViewModel: ObservableObject {
    @Published var nearbySellers: [Seller] = []
    @Published var categories: [String] = ["Lanches", "Bebidas", "Doces", "Salgados", "Saudável"]
    @Published var isLoading = false
    @Published var searchRadius: Double = 1000 // 1km default
    @Published var showOnlyOpen = true
    @Published var sortBy: SortOption = .distance
    
    private let databaseService: DatabaseServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         locationService: LocationServiceProtocol = LocationService()) {
        self.databaseService = databaseService
        self.locationService = locationService
    }
    
    func loadNearbySellers() {
        isLoading = true
        
        // Primeiro, obter localização atual
        locationService.getCurrentLocation()
            .flatMap { [weak self] userLocation -> AnyPublisher<[Seller], Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "BuyerHomeViewModel", code: -1, userInfo: nil))
                        .eraseToAnyPublisher()
                }
                
                // Buscar todos os sellers do Firebase
                return self.databaseService.fetchAll(path: Constants.FirebasePaths.sellers)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading sellers: \(error)")
                }
            } receiveValue: { [weak self] sellers in
                self?.nearbySellers = sellers
                self?.calculateDistances(from: Location(latitude: -23.5505, longitude: -46.6333)) // Default SP location
                        }
                    .store(in: &cancellables)
            }
    
    private func calculateDistances(from userLocation: Location) {
            for i in 0..<self.nearbySellers.count {
                if let sellerLocation = self.nearbySellers[i].currentLocation {
                    let distance = calculateDistance(from: userLocation, to: sellerLocation)
                    self.nearbySellers[i].distance = distance
                }
            }
        }
        
    private func calculateDistance(from loc1: Location, to loc2: Location) -> Double {
        // Cálculo simplificado de distância (Haversine formula seria o ideal)
        let latDiff = loc2.latitude - loc1.latitude
        let lonDiff = loc2.longitude - loc1.longitude
        return sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111 // Aproximação em km
    }
    
    private func loadMockSellers() {
        // Dados mockados para teste
        self.nearbySellers = [
            Seller(
                id: "1",
                userId: "1",
                userEmail: "lanches@ze.com",
                userName: "Zé",
                userPhone: "11999999999",
                businessName: "Lanches do Zé",
                description: "Os melhores lanches da região",
                isOnline: true,
                distance: 45.0,
                currentLocation: Location(latitude: -23.5505, longitude: -46.6333, address: "Rua Exemplo, 123"),
                schedules: [],
                menuId: nil,
                rating: 4.5,
                totalReviews: 42,
                isAvailableNow: true,
                address: "Rua Exemplo, 123",
                profileImageURL: nil,
                createdAt: Date()
            ),
            Seller(
                id: "2",
                userId: "2",
                userEmail: "doces@maria.com",
                userName: "Maria",
                userPhone: "11988888888",
                businessName: "Doces da Maria",
                description: "Doces caseiros e sobremesas",
                isOnline: true,
                distance: 38.2,
                currentLocation: Location(latitude: -23.5510, longitude: -46.6340),
                schedules: [],
                menuId: nil,
                rating: 4.8,
                totalReviews: 28,
                isAvailableNow: true,
                address: "Av. Principal, 456",
                profileImageURL: nil,
                createdAt: Date()
            ),
            Seller(
                id: "3",
                userId: "3",
                userEmail: "sucos@joao.com",
                userName: "João",
                userPhone: "11977777777",
                businessName: "Sucos Naturais João",
                description: "Sucos frescos e saudáveis",
                isOnline: false,
                distance: 23.4,
                currentLocation: Location(latitude: -23.5520, longitude: -46.6350),
                schedules: [],
                menuId: nil,
                rating: 4.2,
                totalReviews: 15,
                isAvailableNow: false,
                address: "Praça Central, 789",
                profileImageURL: nil,
                createdAt: Date()
            )
        ]
        
        // Adicionar distância fictícia
        for i in 0..<self.nearbySellers.count {
            self.nearbySellers[i].distance = Double.random(in: 0.5...5.0)
        }
    }
    
    func refreshLocation() {
        loadNearbySellers()
    }
}
