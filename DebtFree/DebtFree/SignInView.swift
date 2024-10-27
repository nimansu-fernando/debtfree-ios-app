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
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("DebtFreeLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
            
            Text("Sign In")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Welcome to DebtFree!")
                .font(.subheadline)
            
            Spacer()
            
            VStack(spacing: 15) {
                // Continue with Apple
                Button(action: {
                    // Handle Apple Sign In action
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
                    .cornerRadius(10)
                }
                
                // Continue with Google
                Button(action: {
                    // Handle Google Sign In action
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
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }
                
                Divider()
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        // Handle forgot password action
                    }
                    .foregroundColor(.green)
                }
                
                Button(action: {
                    // Handle Sign In action
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            HStack {
                Text("Don’t have an account?")
                Button("Sign Up") {
                    // Navigate to Sign Up
                }
                .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

