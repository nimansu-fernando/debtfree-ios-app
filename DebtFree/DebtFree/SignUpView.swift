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
    
    // Alert State Variables
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var navigateToSignIn = false
    
    // Password validation states
    @State private var hasMinLength = false
    @State private var hasUppercase = false
    @State private var hasNumber = false
    @State private var hasSpecialChar = false
    
    var isPasswordValid: Bool {
        hasMinLength && hasUppercase && hasNumber && hasSpecialChar
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Color("AccentColor1")
                        .frame(height: 180)
                    
                    Color.white
                }
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Logo and titles remain the same...
                    Image("DebtFreeLogo2")
                        .resizable()
                        .frame(width: 257.62, height: 100)
                        .foregroundColor(.green)
                        .padding(.top, 15)
                    
                    Text("Create an Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 15)
                    
                    Text("...and start taking control of your debts!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, -15)
                    
                    // Social Sign in buttons
                    Button(action: signInWithApple) {
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
                    .disabled(isLoading)
                    
                    Button(action: signUpWithGoogle) {
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
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .disabled(isLoading)
                    
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
                    
                    // Email field with validation
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                        .onChange(of: email) { _ in
                            validateEmail()
                        }
                    
                    // Password field with validation indicators
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            
                            Button(action: { isPasswordVisible.toggle() }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                        .onChange(of: password) { _ in
                            validatePassword()
                        }
                        
                        // Password requirements
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                PasswordRequirementView(isValid: hasMinLength, text: "At least 8 characters")
                                    .fixedSize()
                                Text("•")
                                    .foregroundColor(.gray)
                                PasswordRequirementView(isValid: hasUppercase, text: "One uppercase letter")
                                    .fixedSize()
                            }
                            
                            HStack(spacing: 10) {
                                PasswordRequirementView(isValid: hasNumber, text: "One number")
                                    .fixedSize()
                                Text("•")
                                    .foregroundColor(.gray)
                                PasswordRequirementView(isValid: hasSpecialChar, text: "One special character (!@#$)")
                                    .fixedSize()
                            }
                        }
                        .font(.caption2)
                        .padding(.horizontal)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    
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
                    
                    // Sign Up Button with Loading State
                    Button(action: signUp) {
                        ZStack {
                            Text("Sign Up")
                                .foregroundColor(.white)
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .cornerRadius(25)
                    }
                    .disabled(isLoading || !isPasswordValid || !isValidEmail(email))
                    .opacity((isLoading || !isPasswordValid || !isValidEmail(email)) ? 0.6 : 1)
                    .padding(.horizontal, 30)
                    
                    HStack {
                        Text("Have an account?")
                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                                .foregroundColor(Color("SubColor"))
                                .bold()
                        }
                    }
                    
                    NavigationLink(isActive: $navigateToSignIn) {
                        SignInView()
                    } label: {
                        EmptyView()
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        if alertTitle == "Success" {
                            navigateToSignIn = true
                        }
                    }
                )
            }
            .disabled(isLoading)
        }
    }
    
    private func validateEmail() {
        // Email validation happens in real-time as user types
        _ = isValidEmail(email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func validatePassword() {
        hasMinLength = password.count >= 8
        hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        hasSpecialChar = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil
    }
    
    private func signUp() {
        isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        showAlert(title: "Error", message: "An account with this email already exists. Please sign in instead.")
                    case AuthErrorCode.invalidEmail.rawValue:
                        showAlert(title: "Error", message: "Please enter a valid email address.")
                    case AuthErrorCode.weakPassword.rawValue:
                        showAlert(title: "Error", message: "Please choose a stronger password.")
                    default:
                        showAlert(title: "Error", message: error.localizedDescription)
                    }
                } else {
                    showAlert(title: "Success", message: "Your account has been created successfully.")
                    email = ""
                    password = ""
                }
            }
        }
    }
    
    private func signUpWithGoogle() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert(title: "Error", message: "Google Sign In configuration error")
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showAlert(title: "Error", message: "Cannot find root view controller")
            isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                showAlert(title: "Error", message: error.localizedDescription)
                isLoading = false
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                showAlert(title: "Error", message: "Cannot get user data from Google.")
                isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                isLoading = false
                
                if let error = error {
                    showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                showAlert(title: "Success", message: "Successfully signed in with Google!")
            }
        }
    }
    
    private func signInWithApple() {
        // Implement Apple Sign In
        isLoading = true
        // Add your Apple sign-in implementation here
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

struct PasswordRequirementView: View {
    let isValid: Bool
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: isValid ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isValid ? .green : .gray)
            Text(text)
                .foregroundColor(isValid ? .green : .gray)
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
