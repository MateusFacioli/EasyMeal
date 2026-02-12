//
//  StorageService.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseStorage
import UIKit
import Combine

protocol StorageServiceProtocol {
    func uploadImage(_ image: UIImage, path: String) -> AnyPublisher<String, Error>
    func downloadImage(url: String) -> AnyPublisher<UIImage, Error>
    func deleteImage(path: String) -> AnyPublisher<Void, Error>
}

class StorageService: StorageServiceProtocol {
    private let firebaseManager: FirebaseServiceProtocol
    
    init(firebaseManager: FirebaseServiceProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func uploadImage(_ image: UIImage, path: String) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
                return
            }
            
            let ref = self.firebaseManager.storage.reference().child(path)
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            ref.putData(imageData, metadata: metadata) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    ref.downloadURL { url, error in
                        if let error = error {
                            promise(.failure(error))
                        } else if let url = url {
                            promise(.success(url.absoluteString))
                        } else {
                            promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func downloadImage(url: String) -> AnyPublisher<UIImage, Error> {
        Future<UIImage, Error> { promise in
            guard let url = URL(string: url) else {
                promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    promise(.failure(error))
                } else if let data = data, let image = UIImage(data: data) {
                    promise(.success(image))
                } else {
                    promise(.failure(NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to download image"])))
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }
    
    func deleteImage(path: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let ref = self.firebaseManager.storage.reference().child(path)
            ref.delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
