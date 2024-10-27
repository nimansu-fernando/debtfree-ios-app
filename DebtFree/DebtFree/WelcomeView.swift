//
//  WelcomeView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ZStack {
            // Background Image
            Image("welcomeview-bg") // Replace with your background image name
                .resizable()
                //.scaledToFill() // Scale the image to fill the entire area
                .ignoresSafeArea() // Ignore safe area to cover the whole screen
            
            ScrollView { // Add a ScrollView to make content scrollable
                VStack(spacing: 20) {
                    Spacer(minLength: 10) // Add a minimum space at the top
                    
                    Image("DebtFreeLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 250)
                    
                    Text("Welcome to DebtFree!")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 50)
                    
                    Text("Take control of your financial future. Track your debts, prioritize payments, and reach financial freedom with ease.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Spacer() // Space between text and buttons
                    
                    VStack(spacing: 15) {
                        Button(action: {
                            // Navigate to Sign In
                        }) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Navigate to Sign Up
                        }) {
                            Text("Create an Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer() // Space before the footer
                    
                    Text("By continuing, you agree to our")
                        .font(.footnote)
                    HStack(spacing: 5) {
                        Text("Privacy Policy")
                            .foregroundColor(.green)
                        Text("and")
                        Text("Terms of Services")
                            .foregroundColor(.green)
                    }
                    .font(.footnote)
                    
                    Spacer(minLength: 20) // Space at the bottom
                }
                .padding() // General padding for the VStack
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
