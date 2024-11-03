//
//  SignUpView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
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
                    .cornerRadius(10)
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
                        RoundedRectangle(cornerRadius: 10)
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
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color("MainColor"), lineWidth: 1))
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
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color("MainColor"), lineWidth: 1))
                
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

                
                // Sign Up Button
                Button(action: {}) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

