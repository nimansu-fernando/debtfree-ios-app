//
//  SignUpView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import FirebaseCore

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    
    // Alert and Navigation State Variables
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var navigateToSignIn = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Color("AccentColor1")
                        .frame(height: 175)
                    
                    Color.white
                }
                .ignoresSafeArea() // Extends the colors to the edges
                
                VStack(spacing: 20) {
                    // Logo
                    Image("DebtFreeLogo2")
                        .resizable()
                        .frame(width: 257.62, height: 100)
                        .foregroundColor(.green)
                    
                    // Title
                    Text("Create an Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 15)
                    
                    Text("...and start taking control of your debts!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, -15)
                    
                    // Continue with Apple
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
                    
                    // Continue with Google
                    Button(action: {
                        signUpWithGoogle()
                    }) {
                        HStack {
                            Image("google-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Maintain aspect ratio
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
                    
                    Text("Sign up with your email address")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Email TextField
                    TextField("Email", text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    // Password TextField
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
                    
                    // Terms and Privacy Policy
                    VStack(spacing: 4) {
                        Text("By creating an account, you agree to our")
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 6) {
                            Text("Privacy Policy")
                                .foregroundColor(Color("SubColor"))
                            Text("and")
                            Text("Terms of Services")
                                .foregroundColor(Color("SubColor"))
                        }
                        .font(.footnote)
                    }
                    .foregroundColor(.gray)
                    
                    // Sign Up Button with Loading Indicator
                    Button(action: signUp) {
                        if isLoading {
                            /*ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainColor"))
                                .cornerRadius(25)*/
                        } else {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainColor"))
                                .cornerRadius(25)
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Text("Have an account?")
                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                                .foregroundColor(Color("SubColor"))
                                .bold()
                        }
                    }
                    
                    // NavigationLink for successful sign-up navigation
                    NavigationLink(
                        destination: SignInView(),
                        isActive: $navigateToSignIn
                    ) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Sign Up Failed"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Your account has been created successfully."),
                    dismissButton: .default(Text("OK")) {
                        // Navigate to SignInView on alert dismissal
                        navigateToSignIn = true
                    }
                )
            }
        }
    }
    
    func validateFields() -> Bool {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            showErrorAlert = true
            return false
        }
        
        if !email.contains("@") || !email.contains(".") {
            errorMessage = "Please enter a valid email address."
            showErrorAlert = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password should be at least 6 characters."
            showErrorAlert = true
            return false
        }
        
        return true
    }
    
    func signUp() {
        guard validateFields() else { return }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                } else {
                    self.email = ""
                    self.password = ""
                    self.showSuccessAlert = true
                }
            }
        }
    }
    
    func signUpWithGoogle() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Google Sign In configuration error"
            showErrorAlert = true
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Cannot find root view controller"
            showErrorAlert = true
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showErrorAlert = true
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.errorMessage = "Cannot get user data from Google."
                self.showErrorAlert = true
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                    return
                }
                
                guard let user = authResult?.user else {
                    self.errorMessage = "Could not retrieve user data."
                    self.showErrorAlert = true
                    return
                }
                
                // Account created successfully with Google
                self.showSuccessAlert = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
