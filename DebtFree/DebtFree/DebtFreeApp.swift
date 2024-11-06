//
//  DebtFreeApp.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-26.
//

import SwiftUI
import Firebase

@main
struct DebtFreeApp: App {
    let persistenceController = PersistenceController.shared
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            //ContentView()
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
            OnboardingView()
        }
    }
}
