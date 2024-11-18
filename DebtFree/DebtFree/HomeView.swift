//
//  HomeView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-01.
//

import SwiftUI
import CoreData
import FirebaseAuth
import Charts

struct HomeView: View {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    @State private var userName: String = ""
    @State private var progress: Double = 0.0
    @State private var paidAmount: Double = 0.0
    @State private var remainingAmount: Double = 0.0
    @State private var yearsRemaining: Int = 0
    @State private var monthsRemaining: Int = 0
    @State private var targetDate: Date = Date()
    @State private var hasActiveDebts: Bool = false
    @State private var showingAddDebtSheet = false
    
    // CoreData fetch request
    @FetchRequest private var debts: FetchedResults<Debt>
    
    init() {
        let request: NSFetchRequest<Debt> = Debt.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Debt.debtName, ascending: true)]
        request.predicate = NSPredicate(format: "userID == %@", "")
        _debts = FetchRequest(fetchRequest: request)
    }
    
    // Function to get username from email
    private func getUsernameFromEmail(_ email: String) -> String {
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex])
        }
        return email
    }
    
    // Calculate all debt-related metrics
    private func calculateDebtMetrics() {
        // Calculate total paid amount
        paidAmount = debts.reduce(0) { $0 + $1.paidAmount }
        
        // Calculate remaining balance
        let totalBalance = debts.reduce(0) { $0 + ($1.currentBalance - $1.paidAmount) }
        remainingAmount = totalBalance
        
        // Calculate progress percentage
        let totalDebt = paidAmount + remainingAmount
        progress = totalDebt > 0 ? paidAmount / totalDebt : 0
        
        // Update hasActiveDebts
        self.hasActiveDebts = totalDebt > 0
        
        // Calculate debt-free date
        calculateDebtFreeDate()
    }
    
    // Calculate payoff period for individual debt in total months
    private func calculatePayoffPeriod(for debt: Debt) -> Int {
        let remainingBalance = debt.currentBalance - debt.paidAmount
        let monthlyPayment = debt.minimumPayment
        let interestRate = debt.apr / 100 / 12 // Convert annual rate to monthly
        
        // If there's no monthly payment or the debt is paid off
        if monthlyPayment <= 0 || remainingBalance <= 0 {
            return 0
        }
        
        // Calculate number of months needed to pay off the debt with interest
        var numberOfMonths: Double
        
        if interestRate > 0 {
            let monthlyRate = interestRate
            let expression = (monthlyRate * remainingBalance) / monthlyPayment
            numberOfMonths = -log(1 - expression) / log(1 + monthlyRate)
        } else {
            // Simple division if no interest
            numberOfMonths = remainingBalance / monthlyPayment
        }
        
        // Round up to the nearest month
        return Int(ceil(numberOfMonths))
    }
    
    // Calculate when user will be debt-free
    private func calculateDebtFreeDate() {
        // Get payoff periods (in months) for all debts
        let payoffPeriods = debts.map { calculatePayoffPeriod(for: $0) }
        
        // Find the maximum payoff period
        if let maxPayoffPeriod = payoffPeriods.max(), maxPayoffPeriod > 0 {
            // Calculate years and months
            yearsRemaining = maxPayoffPeriod / 12
            monthsRemaining = maxPayoffPeriod % 12
            
            // Calculate target date based on the maximum period
            let calendar = Calendar.current
            targetDate = calendar.date(byAdding: .month, value: maxPayoffPeriod, to: Date()) ?? Date()
            hasActiveDebts = true
        } else {
            // No debts or all debts paid off
            targetDate = Date()
            yearsRemaining = 0
            monthsRemaining = 0
            hasActiveDebts = false
        }
    }
    
    // Progress Chart Data
    private var progressChartData: [(String, Double)] {
        [
            ("Paid", paidAmount),
            ("Remaining", remainingAmount)
        ]
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Custom Header
                HStack {
                    Text("Hi, \(userName)!")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        NavigationLink(destination:
                                        NotificationCenterView()
                                            .navigationTitle("Notifications")
                        ) {
                            Image(systemName: "bell")
                                .font(.system(size: 24))
                                .foregroundColor(Color("MainColor"))
                        }
                        
                        NavigationLink(destination: 
                                        ProfileView()
                                            .navigationTitle("Profile")
                        ) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color("MainColor"))
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 1)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header Card - Debt-Free Countdown
                        ZStack {
                            Rectangle()
                                .fill(Color("CountDownCardColor"))
                                .frame(height: 180)
                                .cornerRadius(12)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("DEBT-FREE COUNTDOWN")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))
                                    .accessibilityLabel("Debt-Free Countdown")
                                
                                if hasActiveDebts {
                                    Text(dateFormatter.string(from: targetDate))
                                        .foregroundColor(.white.opacity(0.9))
                                        .font(.system(size: 18))
                                }
                                
                                HStack {
                                    TimeBlock(value: "\(yearsRemaining)", label: "years")
                                    TimeBlock(value: "\(monthsRemaining)", label: "months")
                                }
                                .padding(.top, hasActiveDebts ? 30 : 50)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            
                            Image("flying-money")
                                .resizable()
                                .frame(width: 170, height: 170)
                                .offset(x: 95, y: 40)
                                .opacity(0.7)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 0.5)
                        
                        // Quick Actions Card (Modified)
                        QuickActionsCard(showingAddDebtSheet: $showingAddDebtSheet)
                        
                        // Progress Card
                        VStack(alignment: .leading, spacing: 25) {
                            Text("Payoff Progress")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.bottom, 5)
                            
                            // Chart Section
                            VStack(spacing: 30) {
                                // Swift Charts Donut Chart
                                Chart(progressChartData, id: \.0) { item in
                                    SectorMark(
                                        angle: .value("Amount", item.1),
                                        innerRadius: .ratio(0.75),
                                        angularInset: 2.0
                                    )
                                    .cornerRadius(3)
                                    .foregroundStyle(by: .value("Category", item.0))
                                }
                                .chartForegroundStyleScale([
                                    "Paid": Color.green.opacity(0.8),
                                    "Remaining": Color.red.opacity(0.8)
                                ])
                                .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                                .frame(height: 200)
                                .overlay {
                                    VStack(spacing: 5) {
                                        Text("\(Int(progress * 100))%")
                                            .font(.system(size: 32, weight: .bold))
                                        Text("PAID")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                }
                                
                                // Amount Details
                                HStack(spacing: 40) {
                                    // Paid Amount
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Paid Amount")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16))
                                        Text("LKR \(String(format: "%.2f", paidAmount))")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 17, weight: .bold))
                                    }
                                    
                                    // Divider
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 1, height: 40)
                                    
                                    // Balance
                                    VStack(alignment: .center, spacing: 8) {
                                        Text("Balance")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 16))
                                        Text("LKR \(String(format: "%.2f", remainingAmount))")
                                            .foregroundColor(.red)
                                            .font(.system(size: 17, weight: .bold))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.horizontal)
                            }
                            .padding(.vertical, 10)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 0.5)
                        
                        // Financial Insights Card
                        FinancialInsightsCard()
                    }
                    .padding()
                }
            }
            .background(Color(.systemGray6))
            .onAppear {
                if let user = Auth.auth().currentUser {
                    // Use email if displayName is nil, then extract username part
                    if let displayName = user.displayName, !displayName.isEmpty {
                        userName = displayName
                    } else if let email = user.email {
                        userName = getUsernameFromEmail(email)
                    } else {
                        userName = "User"
                    }
                    
                    debts.nsPredicate = NSPredicate(format: "userID == %@", user.uid)
                    calculateDebtMetrics()
                }
            }
        }
        .sheet(isPresented: $showingAddDebtSheet) {
            AddDebtView()
        }
    }
}

// Quick Actions Card (Simplified)
struct QuickActionsCard: View {
    @Binding var showingAddDebtSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.system(size: 22, weight: .bold))
            
            HStack(spacing: 20) {
                QuickActionButton(
                    icon: "creditcard.fill",
                    title: "Add Debt",
                    color: .blue
                ) {
                    showingAddDebtSheet.toggle()
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 0.5)
    }
}

// Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// Financial Insights Card
struct FinancialInsightsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Financial Tips")
                .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 5)
            
            VStack(spacing: 20) {
                InsightRow(
                    icon: "dollarsign.circle.fill",
                    color: .green,
                    title: "Snowball Method",
                    description: "Pay minimum on all debts, then put extra money towards smallest debt first."
                )
                
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    color: .blue,
                    title: "High Interest First",
                    description: "Prioritize paying off debts with highest interest rates to save money long-term."
                )
                
                InsightRow(
                    icon: "creditcard.circle.fill",
                    color: .orange,
                    title: "Avoid New Debt",
                    description: "While paying off existing debt, avoid taking on new credit card charges."
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 0.5)
        .padding(.bottom)
    }
}

struct InsightRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
