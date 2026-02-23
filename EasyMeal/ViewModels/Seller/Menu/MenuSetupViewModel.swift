//
//  MenuSetupViewModel.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import SwiftUI
import PhotosUI
import Combine
import FirebaseAuth

class MenuSetupViewModel: ObservableObject {
    @Published var menuItems: [MenuItem] = []
    @Published var newItemName = ""
    @Published var newItemDescription = ""
    @Published var newItemPrice = ""
    @Published var newItemPrepTime = ""
    @Published var selectedCategory = "Lanches"
    @Published var categories = ["Lanches", "Bebidas", "Sobremesas", "Pratos", "Outros"]
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var loadedImages: [UIImage] = []
    @Published var isLoading = false
    
    var canAddMenuItem: Bool {
        !newItemName.isEmpty &&
        !newItemDescription.isEmpty &&
        !newItemPrice.isEmpty &&
        Double(newItemPrice.replacingOccurrences(of: ",", with: ".")) != nil &&
        !newItemPrepTime.isEmpty &&
        Int(newItemPrepTime) != nil
    }
    
    private let databaseService: DatabaseServiceProtocol
    private let storageService: StorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         storageService: StorageServiceProtocol = StorageService()) {
        self.databaseService = databaseService
        self.storageService = storageService
        
        // Observar mudanças nas fotos selecionadas
        $selectedPhotos
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.loadImages(from: items)
            }
            .store(in: &cancellables)
    }
    
    private func loadImages(from items: [PhotosPickerItem]) {
        loadedImages.removeAll()
        
        for item in items {
            item.loadTransferable(type: Data.self) { result in
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.loadedImages.append(image)
                        }
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }
    
    func loadMenu() {
        guard let userId = FirebaseManager.shared.currentUser?.uid else { return }
        
        databaseService.fetch(path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(userId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading seller: \(error)")
                }
            } receiveValue: { [weak self] (seller: Seller) in
                if let menuId = seller.menuId {
                    self?.loadMenuItems(menuId: menuId)
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: TODO VERIFY PATH
    private func loadMenuItems(menuId: String) {
        databaseService.fetch(path: "\(Constants.FirebasePaths.menus)/\(menuId)")
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error loading menu: \(error)")
                }
            } receiveValue: { [weak self] (menu: MenuModel) in // CORRIGIDO: Mudado para MenuModel
                self?.menuItems = menu.items
                self?.categories = Array(Set(menu.categories + (self?.categories ?? [])))
            }
            .store(in: &cancellables)
    }
    
    func addMenuItem() {
        guard let price = Double(newItemPrice.replacingOccurrences(of: ",", with: ".")),
              let prepTime = Int(newItemPrepTime) else { return }
        
        let newItem = MenuItem(
            id: UUID().uuidString,
            name: newItemName,
            description: newItemDescription,
            price: price,
            category: selectedCategory,
            imageURLs: [], // Serão preenchidas após upload
            isAvailable: true,
            preparationTime: prepTime,
            ingredients: []
        )
        
        menuItems.append(newItem)
        
        // Reset form
        newItemName = ""
        newItemDescription = ""
        newItemPrice = ""
        newItemPrepTime = ""
        selectedPhotos.removeAll()
        loadedImages.removeAll()
    }
    
    func deleteMenuItem(at offsets: IndexSet) {
        menuItems.remove(atOffsets: offsets)
    }
    
    func saveMenu() {
        isLoading = true
        
        // Primeiro, fazer upload das imagens
        uploadImages { [weak self] imageURLs in
            guard let self = self else { return }
            
            // Associar imagens aos últimos itens adicionados (simplificado)
            // Na prática, você precisaria de lógica mais complexa para associar imagens a itens específicos
            
            self.saveMenuToDatabase(imageURLs: imageURLs)
        }
    }
    //MARK: TODO VERIFY PATH
    private func uploadImages(completion: @escaping ([String]) -> Void) {
        var uploadedURLs: [String] = []
        let group = DispatchGroup()
        
        for image in loadedImages {
            group.enter()
            storageService.uploadImage(image, path: "menu_items/\(UUID().uuidString).jpg")
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in
                    group.leave()
                }, receiveValue: { url in
                    uploadedURLs.append(url)
                })
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }
    
    private func saveMenuToDatabase(imageURLs: [String]) {
        guard let userId = FirebaseManager.shared.currentUser?.uid else {
            isLoading = false
            return
        }
        
        // Distribuir URLs de imagem para os últimos itens (simplificado)
        // Aqui você precisa de lógica para associar imagens aos itens corretos
        // Por enquanto, vamos associar a todos os itens que não têm imagens
        var updatedItems = menuItems
        for i in 0..<min(imageURLs.count, updatedItems.count) {
            if updatedItems[i].imageURLs.isEmpty {
                updatedItems[i].imageURLs = [imageURLs[i]]
            }
        }
        
        // Criar ou atualizar menu
        let menu = MenuModel( // CORRIGIDO: Mudado para MenuModel
            id: UUID().uuidString,
            sellerId: userId,
            items: updatedItems,
            categories: Array(Set(updatedItems.map { $0.category } + categories)),
            isActive: true,
            lastUpdated: Date()
        )
        //MARK: TODO VERIFY PATH
        // Salvar menu
        databaseService.save(menu, path: "\(Constants.FirebasePaths.menus)/\(menu.id)")
            .flatMap { _ in
                // Atualizar referência no seller
                self.databaseService.update(
                    path: "\(Constants.FirebasePaths.users)/\(Constants.FirebasePaths.sellers)/\(userId)",
                    data: ["menuId": menu.id]
                )
            }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error saving menu: \(error)")
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name("MenuSaved"), object: nil)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
