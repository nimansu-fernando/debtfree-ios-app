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
                            .fill(Color(hex: "0D3B66"))
                            .frame(height: 140)
                            .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DEBT-FREE COUNTDOWN")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                            Text("FEBRUARY 2026")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 14))
                            
                            HStack {
                                TimeBlock(value: "1", label: "years")
                                TimeBlock(value: "4", label: "months")
                            }
                            .padding(.top, 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white.opacity(0.3))
                            .offset(x: 120, y: -20)
                    }
                    
                    // Progress Card
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(lineWidth: 20)
                                .opacity(0.1)
                                .foregroundColor(.blue)
                            
                            Circle()
                                .trim(from: 0.0, to: progress)
                                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                                .foregroundColor(.blue)
                                .rotationEffect(Angle(degrees: 270.0))
                            
                            VStack {
                                Text("\(Int(progress * 100))%")
                                    .font(.title)
                                    .bold()
                                Text("paid")
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: 150, height: 150)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Paid Amount")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("LKR \(String(format: "%.2f", paidAmount))")
                                    .foregroundColor(.green)
                                    .bold()
                            }
                            
                            HStack {
                                Text("Balance")
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("LKR \(String(format: "%.2f", remainingAmount))")
                                    .foregroundColor(.red)
                                    .bold()
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            // View Categories Action
                        }) {
                            Text("View Categories")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    
                    // Timeline Graph placeholder
                    LineGraphView()
                        .frame(height: 200)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Hi, \(userName)!")
            .navigationBarItems(trailing: Button(action: {}) {
                Image(systemName: "bell")
                    .foregroundColor(.blue)
            })
        }
    }
}

struct TimeBlock: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.trailing, 20)
    }
}

struct LineGraphView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Payoff Timeline")
                .font(.headline)
                .padding(.bottom)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addCurve(
                    to: CGPoint(x: 300, y: 150),
                    control1: CGPoint(x: 100, y: 50),
                    control2: CGPoint(x: 200, y: 100)
                )
            }
            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
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
