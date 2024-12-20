//
//  KeychainHelper.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-07.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    
    private init() {}
    
    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key,
                kSecValueData: data
            ] as CFDictionary
            
            SecItemDelete(query) // Delete existing item if exists
            SecItemAdd(query, nil)
        }
    }
    
    func get(forKey key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary
        
        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query, &dataTypeRef) == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    
    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        
        SecItemDelete(query)
    }
    
    func saveCredentials(email: String, password: String) {
        let credentials = "\(email):\(password)"
        save(credentials, forKey: "userCredentials")
    }
    
    func getCredentials() -> (email: String, password: String)? {
        guard let credentialsString = get(forKey: "userCredentials"),
              let separatorIndex = credentialsString.firstIndex(of: ":") else {
            return nil
        }
        
        let email = String(credentialsString[..<separatorIndex])
        let password = String(credentialsString[credentialsString.index(after: separatorIndex)...])
        
        return (email, password)
    }
    
    func saveLastLoggedInUser(email: String, password: String) {
        let credentials = "\(email):\(password)"
        save(credentials, forKey: "lastLoggedInUser")
    }
    
    func getLastLoggedInUser() -> (email: String, password: String)? {
        guard let credentialsString = get(forKey: "lastLoggedInUser"),
              let separatorIndex = credentialsString.firstIndex(of: ":") else {
            return nil
        }
        
        let email = String(credentialsString[..<separatorIndex])
        let password = String(credentialsString[credentialsString.index(after: separatorIndex)...])
        
        return (email, password)
    }
}
