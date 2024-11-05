//
//  DebtsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-02.
//

import SwiftUI

struct DebtView: View {
    @State private var searchText = ""
    @State private var currentPage = 0
    
    // Sample data for the pie chart
    let debts = [
        DebtCategory(name: "Vehicle Loan", amount: 8000, color: .blue),
        DebtCategory(name: "Student Loan", amount: 40000, color: .green),
        DebtCategory(name: "Taxes", amount: 15000, color: .pink),
        DebtCategory(name: "Business Loan", amount: 20000, color: .purple),
        DebtCategory(name: "Other", amount: 10962.19, color: .orange)
    ]
    
    // Sample car debts
    let carDebts = Array(repeating: CarDebt(
        balance: 448037.98,
        minimum: 800000,
        apr: 16.00,
        progress: 0.224
    ), count: 6)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debts")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Plan, track and achieve your payoff goal")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Balance by Category / Debt card with unique headings and indicators
                    VStack(alignment: .leading, spacing: 10) {
                        Text(currentPage == 0 ? "Balance by Category" : "Balance by Debt")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TabView(selection: $currentPage) {
                            PieChartView(debts: debts)
                                .tag(0)
                            PieChartView(debts: debts)
                                .tag(1)
                        }
                        .frame(height: 170)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        // Custom indicator circles
                        HStack {
                            ForEach(0..<2) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.blue : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .mask(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .padding(.bottom, -12) // Extend the mask to include the full height
                    )
                    .padding(.top)

                    
                    // Debts section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Debts")
                                .font(.headline)
                            Spacer()
                            Button(action: {}) {
                                Text("+ Add")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("MainColor"))
                                    .cornerRadius(25)
                            }
                        }
                        
                        // Search bar
                        SearchBar(text: $searchText)
                        
                        // Debt cards
                        ForEach(carDebts.indices, id: \.self) { index in
                            CarDebtCard(debt: carDebts[index])
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    //.cornerRadius(12)
                    .padding(.top)
                }
            }
            .background(Color(.systemGray6))
        }
    }
}

// Structs remain unchanged

struct DebtCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct CarDebt {
    let balance: Double
    let minimum: Double
    let apr: Double
    let progress: Double
}

struct PieChartView: View {
    let debts: [DebtCategory]
    
    var total: Double {
        debts.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack(spacing: 32) {
            // Pie Chart
            ZStack {
                ForEach(debts) { debt in
                    PieSlice(
                        startAngle: .degrees(startAngle(for: debt)),
                        endAngle: .degrees(endAngle(for: debt))
                    )
                    .fill(debt.color)
                }
                Text("$\(String(format: "%.2f", total))")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
            }
            .frame(width: 150, height: 150)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(debts) { debt in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(debt.color)
                            .frame(width: 12, height: 12)
                        Text(debt.name)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
    }
    
    func startAngle(for debt: DebtCategory) -> Double {
        let index = debts.firstIndex(where: { $0.id == debt.id }) ?? 0
        let previousTotal = debts[..<index].reduce(0) { $0 + $1.amount }
        return previousTotal / total * 360
    }
    
    func endAngle(for debt: DebtCategory) -> Double {
        let index = debts.firstIndex(where: { $0.id == debt.id }) ?? 0
        let previousTotal = debts[...index].reduce(0) { $0 + $1.amount }
        return previousTotal / total * 360
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: Angle(degrees: -90) + startAngle,
                   endAngle: Angle(degrees: -90) + endAngle,
                   clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct CarDebtCard: View {
    let debt: CarDebt
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Car")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 24) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: debt.progress)
                        .stroke(Color.blue, lineWidth: 8)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(debt.progress * 100))%")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(width: 60, height: 60)
                
                /// Debt Details
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {  
                        Text("Balance")
                            .foregroundColor(.gray)
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("LKR ")
                                .font(.caption) // Smaller font for "LKR"
                            Text(String(format: "%.2f", debt.balance))
                                .font(.headline) // Regular font for the amount
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minimum")
                                .foregroundColor(.gray)
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("LKR ")
                                    .font(.caption) // Smaller font for "LKR"
                                Text(String(format: "%.2f", debt.minimum))
                                    .font(.body) // Regular font for the amount
                            }
                        }
                        
                        Spacer() // Pushes APR section to the right
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("APR")
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.1f", debt.apr))%")
                                .font(.body)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DebtView_Previews: PreviewProvider {
    static var previews: some View {
        DebtView()
    }
}
