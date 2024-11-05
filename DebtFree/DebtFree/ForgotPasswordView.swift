//
//  ForgotPasswordView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-01.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("forgot-password1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                
                Text("Enter your registered email to receive a verification code")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Email TextField
                TextField("Email", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 30)

                Button(action: {
                    // Action to send verification code
                }) {
                    Text("Send Verification Code")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Action to go back
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
