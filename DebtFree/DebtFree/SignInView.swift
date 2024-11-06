//
//  SignInView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false // Added for password visibility toggle

    var body: some View {
        NavigationStack { // Wrapping the entire view in a NavigationStack for navigation handling
            ZStack {
                VStack(spacing: 0) {
                    Color("AccentColor1") // Adjust the color name as per your design
                        .frame(height: 175)
                    
                    Color.white
                }
                .ignoresSafeArea() // Extends the colors to the edges
                
                VStack(spacing: 20) {
                    // Logo
                    Image("DebtFreeLogo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 257.62, height: 100)

                    // Title
                    Text("Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 15)
                    
                    Text("Welcome to DebtFree!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, -15) // Adjusted spacing to match the SignUpView

                    // Continue with Apple
                    Button(action: {
                        // Apple Sign In
                    }) {
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
                    Button(action: {
                        // Handle Google Sign In
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
                    
                    HStack {
                        Spacer()
                        Button("Forgot Password?") {
                            // Handle forgot password
                        }
                        .foregroundColor(Color("SubColor"))
                    }
                    
                    // Sign In Button
                    Button(action: {
                        // Handle Sign In
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
                    
                    // Text for "Don’t have an account?"
                    HStack {
                        Text("Don’t have an account?")
                        
                        // NavigationLink only for the "Sign Up" button
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .foregroundColor(Color("SubColor"))
                                .bold()
                        }
                    }
                    .padding(.top, 20) // Optionally add padding to adjust placement
                }
                .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
