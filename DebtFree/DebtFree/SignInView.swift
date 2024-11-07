//
//  SignInView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSignedIn = false
    @State private var userName = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Color("AccentColor1")
                        .frame(height: 175)
                    Color.white
                }
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Logo
                    Image("DebtFreeLogo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 257.62, height: 100)

                    Text("Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 15)
                    
                    Text("Welcome to DebtFree!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, -15)

                    // Apple Sign-In (Placeholder)
                    Button(action: {}) {
                        HStack {
                            Image("apple-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Continue with Apple")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(25)
                    }
                    .padding(.top, 20)
                    
                    // Google Sign-In Button
                    Button(action: {
                        signInWithGoogle()
                    }) {
                        HStack {
                            Image("google-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .foregroundColor(.black)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }

                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                        Text("or")
                            .foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    // Password Field
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                    
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            // Handle forgot password
                        }
                        .foregroundColor(Color("SubColor"))
                    }
                    
                    // Sign In Button
                    Button(action: {
                        signInUser()
                    }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("MainColor"))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    HStack {
                        Text("Don’t have an account?")
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .foregroundColor(Color("SubColor"))
                                .bold()
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationDestination(isPresented: $isSignedIn) {
                CustomTabBar()
            }
        }
    }
    
    // Firebase sign-in logic
    private func signInUser() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else if let user = result?.user {
                // Retrieve the display name or use email as fallback
                userName = user.displayName ?? user.email ?? "User"
                isSignedIn = true
            }
        }
    }

    // Google Sign-In logic
    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                alertMessage = "Google sign-in failed."
                showAlert = true
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    alertMessage = error.localizedDescription
                    showAlert = true
                } else {
                    // Successfully signed in with Google
                    isSignedIn = true
                }
            }
        }
    }

    // Helper function to get the root view controller for Google Sign-In
    private func getRootViewController() -> UIViewController {
        let scene = UIApplication.shared.connectedScenes.first
        let windowScene = scene as? UIWindowScene
        return windowScene?.windows.first?.rootViewController ?? UIViewController()
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
