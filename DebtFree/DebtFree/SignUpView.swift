//
//  SignUpView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth


struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var isLoading = false
    
    // Alert State Variables
    @State private var showErrorAlert = false
    @State private var showSuccessAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack { // Use NavigationStack for navigation handling
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
                                .aspectRatio(contentMode: .fit) // Maintain aspect ratio
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
                    Button(action: {}) {
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
                    VStack(spacing: 4) { // Adjust spacing as needed to maintain desired line spacing
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
                    .foregroundColor(.gray) // Apply the gray color to the entire VStack if desired
                    
                    // Sign Up Button with Loading Indicator
                    Button(action: signUp) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainColor"))
                                .cornerRadius(25)
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
                    
                    //Spacer()
                    
                    HStack {
                        Text("Have an account?")
                        
                        // NavigationLink for Sign In button
                        NavigationLink(destination: SignInView()) { // Destination is SignInView
                            Text("Sign In")
                                .foregroundColor(Color("SubColor"))
                                .bold()
                        }
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            // Error Alert
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Sign Up Failed"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Success Alert
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Success"),
                    message: Text("Your account has been created successfully."),
                    dismissButton: .default(Text("OK"), action: {
                        // Optional: Navigate to SignInView or another view
                        // For example:
                        // navigateToSignIn = true
                    })
                )
            }
        }
    }
    
    // Validation Function
    func validateFields() -> Bool {
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields."
            showErrorAlert = true
            return false
        }
        
        // Basic email format check
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
    
    // Sign-Up Function with Firebase Authentication
    func signUp() {
        // Validate fields
        guard validateFields() else { return }
        
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    // Set error message and show error alert
                    self.errorMessage = error.localizedDescription
                    self.showErrorAlert = true
                } else {
                    // Clear input fields and show success alert
                    self.email = ""
                    self.password = ""
                    self.showSuccessAlert = true
                }
            }
        }
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
