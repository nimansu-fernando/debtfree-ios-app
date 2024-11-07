//
//  ProfileView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-07.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var isLoggedOut = false
    
    var body: some View {
        VStack {
            Image("profile_image")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            
            Text("Lakshan Fernando")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink(destination: NotificationsView()) {
                    Text("Notifications")
                        .foregroundColor(.primary)
                }
                
                NavigationLink(destination: FAQView()) {
                    Text("FAQ")
                        .foregroundColor(.primary)
                }
                
                NavigationLink(destination: TermsAndConditionsView()) {
                    Text("Terms and Conditions")
                        .foregroundColor(.primary)
                }
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Privacy Policy")
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 24)
            
            Spacer()
            
            Button(action: {
                logOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom, 24)
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedOut) {
            // Navigate to SignIn View after logout
            SignInView()
        }
    }
    
    func logOut() {
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Remove the user session (uid) from Keychain
            KeychainHelper.shared.delete(forKey: "uid")
            
            // Mark the user as logged out and show the SignIn view
            self.isLoggedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

struct NotificationsView: View {
    var body: some View {
        Text("Notifications View")
    }
}

struct FAQView: View {
    var body: some View {
        Text("FAQ View")
    }
}

struct TermsAndConditionsView: View {
    var body: some View {
        Text("Terms and Conditions View")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy View")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
