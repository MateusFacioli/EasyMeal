//
//  MenuTabViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 11/02/26.
//

import Combine
import Foundation
import SwiftUI

class MenuTabViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var categories: [String] = []
    @Published var isLoading = false
    
    private let databaseService: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService()) {
        self.databaseService = databaseService
    }
    
    func loadMenu(sellerId: String) {
        isLoading = true
        //MARK: TODO VERIFY PATH
        // Primeiro, buscar o seller para pegar o menuId
        databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(sellerId)")
            .flatMap { (seller: Seller) -> AnyPublisher<MenuModel, Error> in
                if let menuId = seller.menuId {
                    return self.databaseService.fetch(path: "\(Constants.FirebasePaths.menus)/\(menuId)")
                } else {
                    return Fail(error: NSError(domain: "MenuTabViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Menu not found"]))
                        .eraseToAnyPublisher()
                }
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error loading menu: \(error)")
                }
            } receiveValue: { [weak self] menu in
                self?.menuItems = menu.items.filter { $0.isAvailable }
                self?.extractCategories(from: menu.items)
            }
            .store(in: &cancellables)
    }
    
    private func extractCategories(from items: [MenuItem]) {
        let uniqueCategories = Set(items.map { $0.category })
        self.categories = Array(uniqueCategories).sorted()
    }
}
