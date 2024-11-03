//
//  HomeView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-01.
//

import SwiftUI

struct DebtTrackerView: View {
    let userName: String
    @State private var progress: Double = 0.224
    @State private var paidAmount: Double = 48037.98
    @State private var remainingAmount: Double = 165962.19
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    ZStack {
                        Rectangle()
                            .fill(Color(hex: "003F59"))
                            .frame(height: 180)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DEBT-FREE COUNTDOWN")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .accessibilityLabel("Debt-Free Countdown")
                            
                            Text("FEBRUARY 2026")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 18))
                            
                            HStack {
                                TimeBlock(value: "1", label: "years")
                                TimeBlock(value: "4", label: "months")
                            }
                            .padding(.top, 30)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        Image("flying-money")
                            .resizable()
                            .frame(width: 170, height: 170)
                            .offset(x: 95, y: 40)
                            .opacity(0.7)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12)) // Clips everything inside ZStack, including the image
                    .shadow(radius: 0.5)
                    
                    // Progress Card Update
                    VStack(alignment: .leading, spacing: 30) {
                        Text("Payoff Progress")
                            .font(.system(size: 20, weight: .bold))
                        
                        HStack(alignment: .center, spacing: 40) {
                            // Adjusted VStack to center its content
                            VStack {
                                ZStack {
                                    Circle()
                                        .stroke(lineWidth: 16) // Increased line width for a bolder look
                                        .foregroundColor(Color.gray.opacity(0.2))
                                    
                                    Circle()
                                        .trim(from: 0.0, to: progress)
                                        .stroke(AngularGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), center: .center), lineWidth: 16)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear, value: progress)
                                    
                                    VStack {
                                        Text("\(Int(progress * 100))%")
                                            .font(.system(size: 24, weight: .bold))
                                        Text("paid")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16))
                                    }
                                }
                                .frame(width: 100, height: 100) // Increased size for a larger chart
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Paid Amount")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                    Text("LKR \(String(format: "%.2f", paidAmount))")
                                        .foregroundColor(.green)
                                        .font(.system(size: 20, weight: .bold))
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Balance")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                    Text("LKR \(String(format: "%.2f", remainingAmount))")
                                        .foregroundColor(.red)
                                        .font(.system(size: 20, weight: .bold))
                                }
                            }
                            .padding(.leading, 8)
                        }
                        .frame(maxWidth: .infinity) // Ensure the HStack takes full width
                        .padding(.horizontal)
                        .frame(minHeight: 120) // Add a minimum height for vertical centering
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 0.5)

                    // Timeline Graph placeholder
                    LineGraphView()
                        .frame(height: 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 0.5)
                }
                .padding()
            }
            .navigationTitle("Hi, \(userName)!")
            .navigationBarItems(
                trailing: HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                }
            )
            .background(Color(.systemGray6)) // Set the background to system grey
        }
    }
}

struct TimeBlock: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.trailing, 20)
    }
}

struct LineGraphView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Text("Payoff Timeline")
                    .font(.headline)
                    .padding(.bottom)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.8))
                    path.addCurve(
                        to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.2),
                        control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.5),
                        control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.4)
                    )
                }
                .stroke(Color.blue.opacity(0.5), lineWidth: 2)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct DebtTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        DebtTrackerView(userName: "Lakshan Fernando")
    }
}
