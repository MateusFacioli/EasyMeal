//
//  FirebaseAuth.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 10/02/26.
//

import FirebaseAuth
import Combine

extension Auth {
    var currentUserPublisher: AnyPublisher<User?, Never> {
        Future<User?, Never> { promise in
            let listener = self.addStateDidChangeListener { _, user in
                promise(.success(user))
            }
            // Manter a referência do listener se necessário
            _ = listener
        }
        .eraseToAnyPublisher()
    }
}

extension AuthServiceProtocol {
    var currentUserPublisher: AnyPublisher<User?, Never> {
        Auth.auth().currentUserPublisher
    }
}
