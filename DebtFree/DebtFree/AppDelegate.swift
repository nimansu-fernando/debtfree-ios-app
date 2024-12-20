//
//  AppDelegate.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-06.
//

import UIKit
import Firebase
import GoogleSignIn

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationManager.shared.resetBadgeCount()
    }
}


