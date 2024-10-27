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
        VStack(spacing: 20) {
            Spacer()
            
            // Logo
            Image(systemName: "dollarsign.circle")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.green)
            
            Text("DEBT\nFREE")
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.green)
            
            // Title
            Text("Create an Account")
                .font(.title)
                .fontWeight(.bold)
            
            Text("...and start taking control of your debts!")
                .font(.subheadline)
                .foregroundColor(.gray)
            
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
            
            // Email TextField
            TextField("Email", text: $email)
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
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
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.blue, lineWidth: 1))
            
            // Terms and Privacy Policy
            Text("By creating an account, you agree to our Privacy Policy and Terms of Services.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            // Sign Up Button
            Button(action: {}) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

