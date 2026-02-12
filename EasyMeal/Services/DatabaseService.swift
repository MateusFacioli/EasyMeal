//
//  DatabaseServiceProtocol.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//


import Foundation
import FirebaseDatabase
import Combine

protocol DatabaseServiceProtocol {
    func save<T: Encodable>(_ object: T, path: String) -> AnyPublisher<Void, Error>
    func fetch<T: Decodable>(path: String) -> AnyPublisher<T, Error>
    func update(path: String, data: [String: Any]) -> AnyPublisher<Void, Error>
    func delete(path: String) -> AnyPublisher<Void, Error>
    func observe<T: Decodable>(path: String) -> AnyPublisher<T, Error>
}

class DatabaseService: DatabaseServiceProtocol {
    private let firebaseManager: FirebaseServiceProtocol
    
    init(firebaseManager: FirebaseServiceProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func save<T: Encodable>(_ object: T, path: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                let json = try JSONEncoder().encode(object)
                let dictionary = try JSONSerialization.jsonObject(with: json) as? [String: Any] ?? [:]
                
                let ref = self.firebaseManager.database.reference().child(path)
                ref.setValue(dictionary) { error, _ in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetch<T: Decodable>(path: String) -> AnyPublisher<T, Error> {
        Future<T, Error> { promise in
            let ref = self.firebaseManager.database.reference().child(path)
            ref.observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value else {
                    promise(.failure(NSError(domain: "DatabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found"])))
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                    promise(.success(decodedObject))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func update(path: String, data: [String: Any]) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let ref = self.firebaseManager.database.reference().child(path)
            ref.updateChildValues(data) { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(path: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let ref = self.firebaseManager.database.reference().child(path)
            ref.removeValue { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func observe<T: Decodable>(path: String) -> AnyPublisher<T, Error> {
        Future<T, Error> { promise in
            let ref = self.firebaseManager.database.reference().child(path)
            ref.observe(.value) { snapshot in
                guard let value = snapshot.value else { return }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: value)
                    let decodedObject = try JSONDecoder().decode(T.self, from: jsonData)
                    // Para observação contínua, precisaríamos de um tipo diferente de publisher
                    promise(.success(decodedObject))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}