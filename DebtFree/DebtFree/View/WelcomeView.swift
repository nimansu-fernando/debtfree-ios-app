//
//  WelcomeView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Color("AccentColor1")
                        .frame(height: 370)
                    
                    Color.white
                }
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Spacer(minLength: 10)
                    
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
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainColor"))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Create an Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainColor"))
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("By continuing, you agree to our")
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
                    .foregroundColor(.gray)
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true) 
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
