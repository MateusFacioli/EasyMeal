//
//  LocationSetupViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import SwiftUI
import Combine
import MapKit
import FirebaseAuth

class LocationSetupViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -23.5505, longitude: -46.6333), // São Paulo
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var selectedLocation: Location?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    var annotations: [Location] {
        guard let location = selectedLocation else { return [] }
        return [location]
    }
    
    private let locationService: LocationServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(locationService: LocationServiceProtocol = LocationService(),
         databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.locationService = locationService
        self.databaseService = databaseService
    }
    
    func checkLocationPermission() {
        locationService.requestPermission()
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            } receiveValue: { status in
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self.useCurrentLocation()
                }
            }
            .store(in: &cancellables)
    }
    
    func useCurrentLocation() {
        isLoading = true
        
        locationService.getCurrentLocation()
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            } receiveValue: { [weak self] location in
                self?.selectedLocation = location
                self?.region.center = location.coordinate
            }
            .store(in: &cancellables)
    }
    
    func saveLocation() {
        guard let location = selectedLocation,
              let userId = FirebaseManager.shared.currentUser?.uid else {
            errorMessage = "Selecione uma localização primeiro"
            showError = true
            return
        }
        
        isLoading = true
        
        let locationData: [String: Any] = [
            "latitude": location.latitude,
            "longitude": location.longitude,
            "address": location.address ?? "",
            "placeName": location.placeName ?? ""
        ]
        
        databaseService.update(path: "\(Constants.FirebasePaths.sellers)/\(userId)", data: ["currentLocation": locationData])
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                } else {
                    // Fechar a view
                    NotificationCenter.default.post(name: NSNotification.Name("LocationSaved"), object: nil)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
