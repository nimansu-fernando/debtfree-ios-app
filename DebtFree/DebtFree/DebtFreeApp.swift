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
    // State to control splash screen visibility
    @State private var showSplash = true
    // State to track first launch
    @State private var isFirstLaunch: Bool
    
    init() {
        // Check if user is signed in
        if let _ = KeychainHelper.shared.get(forKey: "uid") {
            _isSignedIn = State(initialValue: true)
        }
        
        // Check if its first launch
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        _isFirstLaunch = State(initialValue: !hasLaunchedBefore)
        
        // Request notification authorization on app launch
        NotificationManager.shared.requestAuthorization { granted in
            print("Notification permission granted: \(granted)")
        }
        
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "hasLaunchedBefore")
        UserDefaults.standard.synchronize()
    }
    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        NotificationManager.shared.requestAuthorization { granted in
//            // Handle authorization result
//        }
//        return true
//    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen(showSplash: $showSplash)
                        .transition(.opacity)
                        .zIndex(1)
                } else {
                    if isFirstLaunch {
                        OnboardingView()
                            .transition(.opacity)
                            .onAppear {
                                // Set flag that app has been launched before
                                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                            }
                    } else {
                        if isSignedIn {
                            MainTabView()
                                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                                .transition(.opacity)
                        } else {
                            SignInView()
                                .transition(.opacity)
                        }
                    }
                }
            }
            .animation(.easeOut(duration: 0.5), value: showSplash)
        }
    }
}
