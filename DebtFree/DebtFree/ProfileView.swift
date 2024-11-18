//
//  ProfileView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-07.
//

import SwiftUI
import FirebaseAuth
import LocalAuthentication


struct ProfileView: View {
    @State private var isLoggedOut = false
    @State private var isFaceIDEnabled = false
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @StateObject private var biometricManager = BiometricManager()
    @AppStorage ("use_faceid") private var useFaceID = false
    
    // Function to get username from email
    private func getUsernameFromEmail(_ email: String) -> String {
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex])
        }
        return email
    }
    
    // Function to load user data
    private func loadUserData() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? ""
            userName = getUsernameFromEmail(userEmail)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Settings")) {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        Label("FAQ", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: TermsAndConditionsView()) {
                        Label("Terms and Conditions", systemImage: "doc.text.fill")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield.fill")
                    }
                }
                
                Section(header: Text("Security")) {
                    Toggle(isOn: $useFaceID) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.primary)
                            Text("Enable Face ID Login")
                                .foregroundColor(.primary)
                        }
                    }
                    .disabled(!biometricManager.isFaceIDAvailable)
                    .onChange(of: useFaceID) { newValue in
                        if newValue {
                            biometricManager.authenticateWithFaceID { success in
                                if !success {
                                    useFaceID = false
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
                
                Section {
                    Button(action: {
                        logOut()
                    }) {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(25)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isLoggedOut) {
                SignInView()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            KeychainHelper.shared.delete(forKey: "uid")
            UserDefaults.standard.removeObject(forKey: "FaceIDEnabled")
            // Note: We're not clearing lastLoggedInUser credentials
            self.isLoggedOut = true
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showAlert = true
        }
    }
}

// Supporting Views remain the same
struct NotificationsSettingsView: View {
    var body: some View {
        List {
            Toggle("Push Notifications", isOn: .constant(true))
            Toggle("Email Notifications", isOn: .constant(true))
            Toggle("Payment Reminders", isOn: .constant(true))
        }
        .navigationTitle("Notifications")
    }
}

struct FAQView: View {
    var body: some View {
        List {
            Section(header: Text("Common Questions")) {
                Text("How do I add a new debt?")
                Text("How is progress calculated?")
                Text("Can I modify payment schedules?")
            }
        }
        .navigationTitle("FAQ")
    }
}

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            Text("Terms and Conditions")
                .font(.title)
                .padding()
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit...")
                .padding()
        }
        .navigationTitle("Terms & Conditions")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy")
                .font(.title)
                .padding()
            Text("Your privacy is important to us...")
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
