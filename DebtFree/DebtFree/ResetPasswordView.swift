//
//  ResetPasswordView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-01.
//

import SwiftUI

struct ResetPasswordView: View {
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("forgot-password3")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                
                Text("Enter a new password for your account.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                    .padding(.horizontal, 30)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                    .padding(.horizontal, 30)

                Button(action: {
                    // Action to reset password
                }) {
                    Text("Reset Password")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .navigationTitle("Reset Password")
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

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}

