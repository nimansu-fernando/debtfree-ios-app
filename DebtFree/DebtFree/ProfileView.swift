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
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image("user")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        
                        Text("Lakshan Fernando")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                
                Section(header: Text("Settings")) {
                    NavigationLink(destination: NotificationsView()) {
                        Text("Notifications")
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        Text("FAQ")
                    }
                    
                    NavigationLink(destination: TermsAndConditionsView()) {
                        Text("Terms and Conditions")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                    }
                }
                
                Section(header: Text("Security")) {
                    HStack {
                        Text("Face ID")
                        Spacer()
                        Toggle(isOn: $isFaceIDEnabled) {
                           // Text(isFaceIDEnabled ? "Enabled" : "Disabled")
                        }
                        .onChange(of: isFaceIDEnabled, perform: { value in
                            updateFaceIDSetting(enabled: value)
                        })
                    }
                }
                
                Section {
                    Button(action: {
                        logOut()
                    }) {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color("MainColor"))
                            .cornerRadius(25)
                    }
                    //.padding(.top)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isLoggedOut) {
                SignInView()
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
            KeychainHelper.shared.delete(forKey: "uid")
            self.isLoggedOut = true
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func updateFaceIDSetting(enabled: Bool) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if enabled {
                // Enable Face ID - You might save this preference in UserDefaults or a secure location
                print("Face ID enabled")
            } else {
                // Disable Face ID - Handle accordingly
                print("Face ID disabled")
            }
        } else {
            // Biometrics not available
            print("Face ID not available")
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
