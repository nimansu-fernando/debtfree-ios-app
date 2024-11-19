//
//  BiometricManager.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-16.
//

import LocalAuthentication
import SwiftUI
import Firebase
import FirebaseAuth

class BiometricManager: ObservableObject {
    @Published var isFaceIDAvailable = false
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    private let context = LAContext()
    
    init() {
        checkFaceIDAvailability()
    }
    
    private func checkFaceIDAvailability() {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            handleFaceIDError(error)
            isFaceIDAvailable = false
            return
        }
        
        // Specifically check for Face ID
        if context.biometryType == .faceID {
            isFaceIDAvailable = true
        } else {
            errorMessage = "Face ID is not available on this device."
            showError = true
            isFaceIDAvailable = false
        }
    }
    
    func authenticateWithFaceID(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error),
              context.biometryType == .faceID else {
            handleFaceIDError(error)
            completion(false)
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                             localizedReason: "Sign in with Face ID") { [weak self] success, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.handleAuthenticationError(error)
                    completion(false)
                } else {
                    completion(success)
                }
            }
        }
    }
    
    private func handleFaceIDError(_ error: NSError?) {
        if let error = error {
            switch error.code {
            case LAError.biometryNotEnrolled.rawValue:
                errorMessage = "Face ID is not set up. Please set up Face ID in your device settings."
            case LAError.biometryNotAvailable.rawValue:
                errorMessage = "Face ID is not available on this device."
            case LAError.biometryLockout.rawValue:
                errorMessage = "Face ID is locked due to too many failed attempts. Please use your device passcode to re-enable Face ID."
            default:
                errorMessage = "Face ID is not available: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Face ID is not available on this device."
        }
        showError = true
    }
    
    private func handleAuthenticationError(_ error: Error) {
        if let laError = error as? LAError {
            switch laError.code {
            case .userCancel:
                errorMessage = "Face ID authentication was cancelled."
            case .userFallback:
                errorMessage = "Please use Face ID to authenticate."
            case .systemCancel:
                errorMessage = "Face ID authentication was cancelled by the system."
            case .biometryLockout:
                errorMessage = "Face ID is locked due to too many failed attempts. Please use your device passcode to re-enable Face ID."
            case .authenticationFailed:
                errorMessage = "Face ID authentication failed. Please try again."
            default:
                errorMessage = "Face ID authentication error: \(error.localizedDescription)"
            }
        } else {
            errorMessage = "Face ID authentication error: \(error.localizedDescription)"
        }
        showError = true
    }
}
