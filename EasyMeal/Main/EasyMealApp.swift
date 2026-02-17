//
//  EasyMealApp.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 06/02/26.
//

import SwiftUI
import FirebaseCore
import FirebaseDatabaseInternal

@main
struct EasyMealApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .onAppear {
                    FirebaseManager.shared.configure()
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configurar Firebase
//        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
            print("✅ Firebase configurado com sucesso!")
//        }
        
        // Configurar persistência do Realtime Database
        Database.database().isPersistenceEnabled = true
        
        return true
    }
}
