class WriteReviewViewModel: ObservableObject {
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    
    private let databaseService: DatabaseServiceProtocol
    private let storageService: StorageServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(databaseService: DatabaseServiceProtocol = DatabaseService(),
         storageService: StorageServiceProtocol = StorageService()) {
        self.databaseService = databaseService
        self.storageService = storageService
    }
    
    func submitReview(sellerId: String, rating: Int, comment: String, images: [UIImage], completion: @escaping () -> Void) {
        guard let userId = FirebaseManager.shared.currentUser?.uid,
              let userName = FirebaseManager.shared.currentUser?.displayName ?? "Cliente" else {
            return
        }
        
        isSubmitting = true
        
        // Upload das imagens
        var imageURLs: [String] = []
        let group = DispatchGroup()
        
        for image in images {
            group.enter()
            storageService.uploadImage(image, path: "reviews/\(sellerId)/\(UUID().uuidString).jpg")
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { _ in
                    group.leave()
                }, receiveValue: { url in
                    imageURLs.append(url)
                })
                .store(in: &cancellables)
        }
        
        group.notify(queue: .main) {
            let review = Review(
                id: UUID().uuidString,
                sellerId: sellerId,
                userId: userId,
                userName: userName,
                rating: rating,
                comment: comment,
                imageURLs: imageURLs,
                date: Date(),
                helpfulCount: 0,
                sellerReply: nil
            )
            
            // Salvar review
            self.databaseService.save(review, path: "\(Constants.FirebasePaths.reviews)/\(sellerId)/\(review.id)")
                .receive(on: RunLoop.main)
                .sink { result in
                    self.isSubmitting = false
                    if case .failure(let error) = result {
                        self.errorMessage = error.localizedDescription
                    } else {
                        completion()
                    }
                } receiveValue: { _ in }
                .store(in: &self.cancellables)
        }
    }
}