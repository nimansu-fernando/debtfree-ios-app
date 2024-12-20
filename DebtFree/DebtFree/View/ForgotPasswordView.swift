//
//  ForgotPasswordView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-01.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var errorMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> // To go back to SignInView
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Forgot Password")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                Image("forgot-password1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                
                Text("Enter your registered email to receive the password reset link")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal, 30)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                // Button to send reset link
                Button(action: handlePasswordReset) {
                    Text("Send Reset Link")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("MainColor"))
                        .foregroundColor(.white)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"), action: {
                        if alertTitle == "Password Reset Complete" {
                            presentationMode.wrappedValue.dismiss()
                        }
                    })
                )
            }
        }
    }
    
    // Password Reset Function
    private func handlePasswordReset() {
        guard !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                showError(error.localizedDescription)
                return
            }
            
            showError("If this email is associated with an account, you will receive a password reset link shortly.", isSuccess: true)
        }
    }
    
    // Show error or success message
    private func showError(_ message: String, isSuccess: Bool = false) {
        alertMessage = message
        alertTitle = isSuccess ? "Password Reset Complete" : "Error"
        showAlert = true 
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}

