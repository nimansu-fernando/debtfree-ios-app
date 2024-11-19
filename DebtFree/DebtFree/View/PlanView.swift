//
//  PlanView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import Foundation
import SwiftUI
import CoreData
import FirebaseAuth
import Charts

struct PlanSummary {
    var nextDebtPayoff: String
    var allDebtsPayoff: String
    var nextMonthInterest: Double
    var totalInterest: Double
    var nextMonthPayment: Double
    var totalPayments: Double
    var currentFocusDebt: Debt?
    var nextSnowballDebt: Debt?
    var settledDebts: [Debt]
}

struct PlanView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var planSummary: PlanSummary?
    @State private var userID: String = ""
    @State private var selectedDebt: Debt?
    
    @FetchRequest private var debts: FetchedResults<Debt>
    
    init() {
        let request: NSFetchRequest<Debt> = Debt.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Debt.currentBalance, ascending: true),
            NSSortDescriptor(keyPath: \Debt.apr, ascending: false)
        ]
        request.predicate = NSPredicate(format: "userID == %@", "")
        _debts = FetchRequest(fetchRequest: request)
    }
    
    private func calculatePlanSummary() {
        // Get all debts with completed payments
        let completedDebtIDs = debts.compactMap { debt -> UUID? in
            let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "debtID == %@", debt.debtID! as CVarArg)
            
            do {
                let payments = try viewContext.fetch(fetchRequest)
                // A debt is settled if it has payments and all are completed
                return (!payments.isEmpty && payments.allSatisfy { $0.status == "completed" }) ? debt.debtID : nil
            } catch {
                print("Error fetching payments: \(error)")
                return nil
            }
        }
        
        // Filter debts based on completed payments
        let settledDebts = debts.filter { completedDebtIDs.contains($0.debtID!) }
        let activeDebts = debts.filter { !completedDebtIDs.contains($0.debtID!) }
        
        // Sort active debts by remaining balance
        let sortedActiveDebts = activeDebts.sorted {
            ($0.currentBalance - $0.paidAmount) < ($1.currentBalance - $1.paidAmount)
        }
        
        let currentFocusDebt = sortedActiveDebts.first
        let nextSnowballDebt = sortedActiveDebts.count > 1 ? sortedActiveDebts[1] : nil
        
        // Calculate payoff dates
        let nextDebtPayoff = currentFocusDebt?.calculatePayoffDate() ?? Date()
        let allDebtsPayoff = calculateAllDebtsPayoffDate(debts: activeDebts)
        
        // Calculate interest and payments
        var nextMonthInterest: Double = 0
        var totalInterest: Double = 0
        var nextMonthPayment: Double = 0
        var totalPayments: Double = 0
        
        for debt in activeDebts {
            let monthlyRate = debt.apr / (100.0 * 12.0)
            let balance = debt.currentBalance - debt.paidAmount
            
            // Next month interest and payment
            let monthInterest = balance * monthlyRate
            nextMonthInterest += monthInterest
            nextMonthPayment += debt.minimumPayment
            
            // Total interest and payments calculation
            let (_, interestPaid) = calculateTotalInterestAndPayments(debt: debt)
            totalInterest += interestPaid
            totalPayments += balance + interestPaid
        }
        
        // Create summary
        planSummary = PlanSummary(
            nextDebtPayoff: formatTimeRemaining(from: Date(), to: nextDebtPayoff),
            allDebtsPayoff: formatTimeRemaining(from: Date(), to: allDebtsPayoff),
            nextMonthInterest: nextMonthInterest,
            totalInterest: totalInterest,
            nextMonthPayment: nextMonthPayment,
            totalPayments: totalPayments,
            currentFocusDebt: currentFocusDebt,
            nextSnowballDebt: nextSnowballDebt,
            settledDebts: Array(settledDebts)
        )
    }
    
    private func calculateAllDebtsPayoffDate(debts: [Debt]) -> Date {
        var totalMonths: Int = 0
        
        for debt in debts {
            let balance = debt.currentBalance - debt.paidAmount
            let payment = debt.minimumPayment
            let monthlyRate = debt.apr / (100.0 * 12.0)
            
            if monthlyRate > 0 {
                // Using amortization formula
                let monthsToPayoff = -log(1 - (monthlyRate * balance) / payment) / log(1 + monthlyRate)
                totalMonths = max(totalMonths, Int(ceil(monthsToPayoff)))
            } else {
                let monthsToPayoff = balance / payment
                totalMonths = max(totalMonths, Int(ceil(monthsToPayoff)))
            }
        }
        
        return Calendar.current.date(byAdding: .month, value: totalMonths, to: Date()) ?? Date()
    }
    
    private func calculateTotalInterestAndPayments(debt: Debt) -> (totalPayments: Double, totalInterest: Double) {
        let balance = debt.currentBalance - debt.paidAmount
        let payment = debt.minimumPayment
        let monthlyRate = debt.apr / (100.0 * 12.0)
        
        var remainingBalance = balance
        var totalInterest: Double = 0
        
        while remainingBalance > 0 {
            let monthlyInterest = remainingBalance * monthlyRate
            totalInterest += monthlyInterest
            
            let principalPayment = min(payment - monthlyInterest, remainingBalance)
            remainingBalance -= principalPayment
            
            if monthlyInterest >= payment {
                return (balance, Double.infinity)
            }
        }
        
        return (balance + totalInterest, totalInterest)
    }
    
    private func formatTimeRemaining(from start: Date, to end: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: start, to: end)
        
        if let years = components.year, years > 0 {
            if let months = components.month, months > 0 {
                return "\(years) Years \(months) Months"
            }
            return "\(years) Years"
        } else if let months = components.month, months > 0 {
            if let days = components.day, days > 0 {
                return "\(months) Months \(days) Days"
            }
            return "\(months) Months"
        } else if let days = components.day {
            return "\(days) Days"
        }
        
        return "0 Days"
    }
    
    private func getLastPayment(for debt: Debt) -> Payment? {
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "debtID == %@ AND status == %@",
                                             debt.debtID! as CVarArg,
                                             "completed")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Payment.paidDate,
                                                         ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let payments = try viewContext.fetch(fetchRequest)
            return payments.first
        } catch {
            print("Error fetching last payment: \(error)")
            return nil
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getTotalAmountPaid(for debt: Debt) -> Double {
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "debtID == %@ AND status == %@",
                                             debt.debtID! as CVarArg,
                                             "completed")
        
        do {
            let payments = try viewContext.fetch(fetchRequest)
            return payments.reduce(0.0) { $0 + $1.amountPaid }
        } catch {
            print("Error fetching payments: \(error)")
            return 0.0
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Payoff Plan")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Track your progress and stay on course to debt freedom")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    if let summary = planSummary {
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
                                leftValue: summary.nextDebtPayoff,
                                rightLabel: "All Debts",
                                rightValue: summary.allDebtsPayoff,
                                strokeColor: Color("Color3"),
                                strokeWidth: 5
                            )
                            
                            // Interest Card
                            SummaryCard(
                                icon: "percent",
                                iconColor: .red,
                                title: "Interest",
                                leftLabel: "Next 30 Days",
                                leftValue: String(format: "LKR %.2f", summary.nextMonthInterest),
                                rightLabel: "Total",
                                rightValue: String(format: "LKR %.2f", summary.totalInterest),
                                strokeColor: Color("Color4"),
                                strokeWidth: 5
                            )
                            
                            // Payments Card
                            SummaryCard(
                                icon: "dollarsign.circle.fill",
                                iconColor: .blue,
                                title: "Payments",
                                leftLabel: "Next 30 Days",
                                leftValue: String(format: "LKR %.2f", summary.nextMonthPayment),
                                rightLabel: "Total",
                                rightValue: String(format: "LKR %.2f", summary.totalPayments),
                                strokeColor: Color("Color5"),
                                strokeWidth: 5
                            )
                        }
                        
                        // Current Focus Debt Section
                        if let focusDebt = summary.currentFocusDebt {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Current Focus Debt")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                NavigationLink(destination: DebtDetailsView(debt: focusDebt)
                                    .navigationTitle(focusDebt.debtName ?? "Debt Details")
                                    .navigationBarTitleDisplayMode(.inline)
                                ) {
                                    DebtInfoCard(
                                        title: focusDebt.debtName ?? "Unknown",
                                        balance: focusDebt.currentBalance - focusDebt.paidAmount,
                                        minimum: focusDebt.minimumPayment,
                                        apr: focusDebt.apr,
                                        progress: focusDebt.paidAmount / focusDebt.currentBalance,
                                        debt: focusDebt
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Next Snowball Target Section
                        if let nextDebt = summary.nextSnowballDebt {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Next Snowball Target")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                NavigationLink(destination: DebtDetailsView(debt: nextDebt)
                                    .navigationTitle(nextDebt.debtName ?? "Debt Details")
                                    .navigationBarTitleDisplayMode(.inline)
                                ) {
                                    DebtInfoCard(
                                        title: nextDebt.debtName ?? "Unknown",
                                        balance: nextDebt.currentBalance - nextDebt.paidAmount,
                                        minimum: nextDebt.minimumPayment,
                                        apr: nextDebt.apr,
                                        progress: nextDebt.paidAmount / nextDebt.currentBalance,
                                        debt: nextDebt
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        
                        // Settled Debts Section
                        if !summary.settledDebts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Settled Debts")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(summary.settledDebts) { debt in
                                    let lastPayment = getLastPayment(for: debt)
                                    let totalPaid = getTotalAmountPaid(for: debt)
                                    SettledDebtCard(
                                        name: debt.debtName ?? "Unknown",
                                        amount: totalPaid,
                                        date: formatDate(lastPayment?.paidDate ?? Date())
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .background(Color(.systemGray6))
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.userID = user.uid
                    updateFetchRequest()
                    calculatePlanSummary()
                }
            }
            .onChange(of: userID) { oldValue, newValue in
                updateFetchRequest()
                calculatePlanSummary()
            }
            .onChange(of: debts.count) { oldValue, newValue in
                calculatePlanSummary()
            }
        }
    }
    
    private func updateFetchRequest() {
        debts.nsPredicate = NSPredicate(format: "userID == %@", userID)
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
    let strokeColor: Color
    let strokeWidth: CGFloat
    
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
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeColor, lineWidth: strokeWidth)
        )
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
    let debt: Debt
    
    private var chartData: [ProgressData] {
        [
            ProgressData(type: "Paid", value: progress * 100),
            ProgressData(type: "Remaining", value: (1 - progress) * 100)
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .foregroundColor(.black)
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 24) {
                // Progress Chart
                Chart(chartData) { segment in
                    SectorMark(
                        angle: .value("Progress", segment.value),
                        innerRadius: .ratio(0.8),
                        angularInset: 1.0
                    )
                    .foregroundStyle(segment.type == "Paid" ? Color.blue : Color.blue.opacity(0.2))
                }
                .frame(width: 60, height: 60)
                .overlay {
                    Text("\(Int(progress * 100))%")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Balance")
                            .foregroundColor(.gray)
                        Text("LKR \(String(format: "%.2f", balance))")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minimum")
                                .foregroundColor(.gray)
                            Text("LKR \(String(format: "%.2f", minimum))")
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("APR")
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.2f", apr))%")
                                .foregroundColor(.black)
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
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(name)
                        .font(.headline)
                }
                
                Text("Total Paid: LKR \(String(format: "%.2f", amount))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("SETTLED")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(4)
                
                Text("Completed on")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
    }
}
