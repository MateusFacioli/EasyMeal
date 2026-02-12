//
//  LocationService.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import CoreLocation
import Combine

protocol LocationServiceProtocol {
    func getCurrentLocation() -> AnyPublisher<Location, Error>
    func requestPermission() -> AnyPublisher<CLAuthorizationStatus, Error>
}

class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationPromise: ((Result<Location, Error>) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    func getCurrentLocation() -> AnyPublisher<Location, Error> {
        Future<Location, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "LocationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])))
                return
            }
            
            // Verificar permissão
            let status = self.locationManager.authorizationStatus
            
            switch status {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
                self.locationPromise = { result in
                    switch result {
                    case .success(let location):
                        promise(.success(location))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
                
            case .restricted, .denied:
                promise(.failure(NSError(domain: "LocationService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Location permission denied"])))
                
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationPromise = { result in
                    switch result {
                    case .success(let location):
                        promise(.success(location))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
                self.locationManager.requestLocation()
                
            @unknown default:
                promise(.failure(NSError(domain: "LocationService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"])))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func requestPermission() -> AnyPublisher<CLAuthorizationStatus, Error> {
        Future<CLAuthorizationStatus, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "LocationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Service not available"])))
                return
            }
            
            let status = self.locationManager.authorizationStatus
            
            if status == .notDetermined {
                self.locationManager.requestWhenInUseAuthorization()
                // Não podemos prometer o resultado aqui, então retornamos o status atual
                promise(.success(status))
            } else {
                promise(.success(status))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationPromise?(.failure(NSError(domain: "LocationService", code: -4, userInfo: [NSLocalizedDescriptionKey: "No location data"])))
            locationPromise = nil
            return
        }
        
        let customLocation = Location(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        // Reverse geocoding para obter endereço
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error)")
                // Ainda retornamos a localização, apenas sem endereço
                self?.locationPromise?(.success(customLocation))
            } else if let placemark = placemarks?.first {
                var updatedLocation = customLocation
                updatedLocation.address = [
                    placemark.thoroughfare,
                    placemark.subThoroughfare,
                    placemark.locality,
                    placemark.administrativeArea
                ].compactMap { $0 }.joined(separator: ", ")
                updatedLocation.placeName = placemark.name ?? placemark.locality
                
                self?.locationPromise?(.success(updatedLocation))
            } else {
                self?.locationPromise?(.success(customLocation))
            }
            self?.locationPromise = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationPromise?(.failure(error))
        locationPromise = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Se já temos uma promise pendente, solicitar localização
            if locationPromise != nil {
                locationManager.requestLocation()
            }
        } else if status == .denied || status == .restricted {
            locationPromise?(.failure(NSError(domain: "LocationService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Location permission denied"])))
            locationPromise = nil
        }
    }
}
