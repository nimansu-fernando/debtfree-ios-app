//
//  OnboardingView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-26.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    let totalPages = 3

    var body: some View {
        ZStack {
            // Background image
            Image("onboarding-bg") // Replace with your background image asset name
                .resizable()
                .edgesIgnoringSafeArea(.all) // Extend background to all screen edges

            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPageView(
                        imageName: "money",
                        title: "Welcome to DebtFree!",
                        description: "Your journey to financial freedom starts here. Track, manage, and pay off your debts with ease."
                    )
                    .tag(0)

                    OnboardingPageView(
                        imageName: "onboarding2-graphic",
                        title: "Track Your Debts, Simplify Payments",
                        description: "Add all your debts, from loans to credit cards, and watch as DebtFree helps you prioritize payments with the Snowball Method."
                    )
                    .tag(1)

                    OnboardingPageView(
                        imageName: "onboarding3-graphic",
                        title: "Stay on Top of Your Payments",
                        description: "Get reminders for upcoming payments and track your progress toward total financial freedom. With DebtFree, you’ll never miss a payment!"
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // Hide default indicator dots

                Spacer() // Pushes the following views to the bottom

                // Custom page indicator dots with tap functionality
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(currentPage == index ? .blue : .gray)
                            .onTapGesture {
                                currentPage = index // Set the current page to the tapped dot
                            }
                    }
                }
                .padding(.bottom, 20) // Adjust bottom padding as needed

                // Button and Skip Link
                VStack(spacing: 10) {
                    Button(action: {
                        if currentPage < totalPages - 1 {
                            currentPage += 1
                        } else {
                            // Action when onboarding is completed
                        }
                    }) {
                        Text(currentPage < totalPages - 1 ? "Next" : "Let's Get Started!")
                            .frame(width: 268)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)

                    if currentPage < totalPages - 1 {
                        Button("Skip") {
                            // Action for skip button
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom)
            }
            .padding(.bottom, 40) // Additional padding if needed
        }
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .padding(.top, 10)
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
