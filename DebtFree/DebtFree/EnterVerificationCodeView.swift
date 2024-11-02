//
//  EnterVerificationCodeView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-01.
//

import SwiftUI

struct EnterVerificationCodeView: View {
    @State private var code: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("forgot-password2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                
                Text("We’ve sent a verification code to your email. Please enter the code to reset your password.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Single TextField for the verification code
                TextField("Enter Verification Code", text: $code)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color("MainColor"), lineWidth: 1))
                    .keyboardType(.numberPad)
                    .padding(.horizontal, 30)

                Button(action: {
                    // Action to verify the code
                }) {
                    Text("Verify Code")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                Text("Didn’t receive the code? ")
                    .font(.subheadline)
                + Text("Resend")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryColor"))

                Spacer()
            }
            .navigationTitle("Enter Verification Code")
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

struct EnterVerificationCodeView_Previews: PreviewProvider {
    static var previews: some View {
        EnterVerificationCodeView()
    }
}
