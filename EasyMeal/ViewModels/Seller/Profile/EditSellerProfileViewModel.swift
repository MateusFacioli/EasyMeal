//
//  EditSellerProfileViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//


import Foundation
import Combine
import UIKit
import FirebaseAuth

class EditSellerProfileViewModel: ObservableObject {
    @Published var businessName = ""
    @Published var description = ""
    @Published var phone = ""
    @Published var address = ""
    @Published var profileImage: UIImage?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let databaseService: DatabaseServiceProtocol
    private let storageService: StorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var hasChanges: Bool {
        return !businessName.isEmpty || !description.isEmpty
    }
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         storageService: StorageServiceProtocol = StorageService()) {
        self.databaseService = databaseService
        self.storageService = storageService
    }
    
    func loadProfile() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        isLoading = true
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Erro ao carregar perfil: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] (seller: Seller) in
                self?.businessName = seller.businessName
                self?.description = seller.description
                self?.phone = seller.userPhone
                self?.address = seller.address ?? ""
                
                // Carregar imagem de perfil se existir
                if let imageUrl = seller.profileImageURL {
                    self?.loadProfileImage(from: imageUrl)
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { UIImage(data: $0) }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] image in
                self?.profileImage = image
            })
            .store(in: &cancellables)
    }
    
    func saveChanges(completion: @escaping () -> Void) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else {
            errorMessage = "Usuário não autenticado"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        // Se houver imagem para upload, fazer upload primeiro
        if let image = profileImage {
            uploadProfileImage(image, userId: userId) { [weak self] imageUrl in
                self?.saveSellerProfile(userId: userId, profileImageURL: imageUrl, completion: completion)
            }
        } else {
            saveSellerProfile(userId: userId, profileImageURL: nil, completion: completion)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage, userId: String, completion: @escaping (String?) -> Void) {
        storageService.uploadImage(image, path: "seller_profile/\(userId).jpg")
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorMessage = "Erro ao fazer upload da imagem: \(error.localizedDescription)"
                    completion(nil)
                }
            } receiveValue: { imageUrl in
                completion(imageUrl)
            }
            .store(in: &cancellables)
    }
    
    private func saveSellerProfile(userId: String, profileImageURL: String?, completion: @escaping () -> Void) {
        let updates: [String: Any] = [
            "businessName": businessName,
            "description": description,
            "userPhone": phone,
            "address": address,
            "profileImageURL": profileImageURL as Any,
            "updatedAt": Date().timeIntervalSince1970
        ]
        
        databaseService.update(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(userId)", data: updates)
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = "Erro ao salvar perfil: \(error.localizedDescription)"
                } else {
                    self?.successMessage = "Perfil atualizado com sucesso!"
                    // Aguardar um pouco antes de completar
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        completion()
                    }
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func updateLocation(completion: @escaping (Location) -> Void) {
        let locationService = LocationService()
        locationService.getCurrentLocation()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorMessage = "Erro ao obter localização: \(error.localizedDescription)"
                }
            } receiveValue: { location in
                completion(location)
            }
            .store(in: &cancellables)
    }
}
