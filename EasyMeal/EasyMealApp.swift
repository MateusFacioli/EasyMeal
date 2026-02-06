//
//  EasyMealApp.swift
//  EasyMeal
//
//  Created by Mateus Rodrigues on 06/02/26.
//

import SwiftUI
import CoreData

@main
struct EasyMealApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
