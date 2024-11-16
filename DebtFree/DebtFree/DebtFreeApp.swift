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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    // State to track if user is signed in
    @State private var isSignedIn = false

    // Check if user session is active on view appear
    init() {
        if let _ = KeychainHelper.shared.get(forKey: "uid") {
            _isSignedIn = State(initialValue: true)
        }
    }

    var body: some Scene {
        WindowGroup {
            if isSignedIn {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            } else {
                SignInView()
            }
        }
    }
}

/*import SwiftUI
import Firebase

@main
struct DebtFreeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    let persistenceController = PersistenceController.shared
    /*init() {
        FirebaseApp.configure()
    }*/
    var body: some Scene {
        WindowGroup {
            //ContentView()
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
            //OnboardingView()
            //SignUpView()
            SignInView()
            //CustomTabBar()
        }
    }
}*/
