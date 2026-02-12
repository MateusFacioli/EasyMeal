//
//  DatabaseService.swift
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
    func fetchAll<T>(path: String) -> AnyPublisher<[T], Error> where T : Decodable
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
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .secondsSince1970
                let json = try encoder.encode(object)
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
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .secondsSince1970
                    let decodedObject = try decoder.decode(T.self, from: jsonData)
                    promise(.success(decodedObject))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchAll<T: Decodable>(path: String) -> AnyPublisher<[T], Error> {
            Future<[T], Error> { promise in
                let ref = self.firebaseManager.database.reference().child(path)
                ref.observeSingleEvent(of: .value) { snapshot in
                    guard let value = snapshot.value as? [String: Any] else {
                        promise(.success([])) // Retorna array vazio se não houver dados
                        return
                    }
                    
                    var items: [T] = []
                    for (_, dictValue) in value {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: dictValue)
                            let decoder = JSONDecoder()
                            decoder.dateDecodingStrategy = .secondsSince1970
                            let decodedObject = try decoder.decode(T.self, from: jsonData)
                            items.append(decodedObject)
                        } catch {
                            print("Error decoding item: \(error)")
                        }
                    }
                    
                    promise(.success(items))
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
