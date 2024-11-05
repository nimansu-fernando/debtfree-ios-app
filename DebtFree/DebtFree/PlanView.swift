//
//  PlanView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI

struct PlanView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payoff Plan")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Track your progress and stay on course to debt freedom")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Plan Summary Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Plan Summary")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Payoff Card
                        SummaryCard(
                            icon: "trophy.fill",
                            iconColor: .green,
                            title: "Payoff",
                            leftLabel: "Next Debt",
                            leftValue: "1 Month 5 Days",
                            rightLabel: "All Debts",
                            rightValue: "5 Years 10 Months"
                        )
                        
                        // Interest Card
                        SummaryCard(
                            icon: "percent",
                            iconColor: .red,
                            title: "Interest",
                            leftLabel: "Next 30 Days",
                            leftValue: "LKR 10,000",
                            rightLabel: "Total",
                            rightValue: "LKR 126,000"
                        )
                        
                        // Payments Card
                        SummaryCard(
                            icon: "dollarsign.circle.fill",
                            iconColor: .blue,
                            title: "Payments",
                            leftLabel: "Next 30 Days",
                            leftValue: "LKR 156,000",
                            rightLabel: "Total",
                            rightValue: "LKR 105,562,000"
                        )
                    }
                    
                    // Current Focus Debt Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Current Focus Debt")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        DebtInfoCard(
                            title: "Car",
                            balance: 448037.98,
                            minimum: 8000.00,
                            apr: 16.00,
                            progress: 0.984
                        )
                    }
                    
                    // Next Snowball Target Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Next Snowball Target")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        DebtInfoCard(
                            title: "Degree",
                            balance: 448037.98,
                            minimum: 8000.00,
                            apr: 16.00,
                            progress: 0.224
                        )
                    }
                    
                    // Debts Paid Off Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Debts Paid Off")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            SettledDebtCard(name: "Bike Loan", amount: 500000.00, date: "May 22, 2024")
                            SettledDebtCard(name: "Land Loan", amount: 500000.00, date: "May 22, 2024")
                            SettledDebtCard(name: "Shop Loan", amount: 500000.00, date: "May 22, 2024")
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80) // Add padding for tab bar
            }
            .background(Color(.systemGray6))
        }
    }
}

struct SummaryCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let leftLabel: String
    let leftValue: String
    let rightLabel: String
    let rightValue: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(leftLabel)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(leftValue)
                        .font(.system(.body, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(rightLabel)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(rightValue)
                        .font(.system(.body, design: .rounded))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct DebtInfoCard: View {
    let title: String
    let balance: Double
    let minimum: Double
    let apr: Double
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 24) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.blue, lineWidth: 8)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(progress * 100))%")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Balance")
                            .foregroundColor(.gray)
                        Text("LKR \(String(format: "%.2f", balance))")
                            .font(.headline)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minimum")
                                .foregroundColor(.gray)
                            Text("LKR \(String(format: "%.2f", minimum))")
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("APR")
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.2f", apr))%")
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SettledDebtCard: View {
    let name: String
    let amount: Double
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text("LKR \(String(format: "%.2f", amount))")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("SETTLED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
                
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
