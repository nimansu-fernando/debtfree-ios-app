//
//  SplashView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isAnimating = false
    @State private var fadeIn = false
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 1.0),
                    Color(red: 0.55, green: 1.0, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                // Logo and Text combined image
                Image("DebtFreeLogo2") // Make sure to add this image to your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(fadeIn ? 1 : 0)
                
                // Tagline
                Text("A Clear Path to Financial Freedom")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                    .opacity(fadeIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                isAnimating = true
            }
            
            withAnimation(.easeIn(duration: 0.8)) {
                fadeIn = true
            }
            
            // Transition to main screen after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

// Main App View that manages the splash screen
struct MainView: View {
    @State private var showSplash = true
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen(showSplash: $showSplash)
                    .transition(.opacity)
            } else {
                // Your main app content here
                OnboardingView()
                    .transition(.opacity)
            }
        }
    }
}

// Preview provider
struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
