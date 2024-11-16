//
//  DebtDetailsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI
import CoreData
import Charts

// Move EditableField enum outside the view and make it conform to Identifiable
enum EditableField: String, Identifiable {
    case debtName
    case lenderName
    case currentBalance
    case apr
    case minimumPayment
    case minimumPaymentCalc
    case paymentFrequency
    case nextPaymentDate
    case notes
    
    // Required by Identifiable protocol
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .debtName: return "Debt Name"
        case .lenderName: return "Lending Institution"
        case .currentBalance: return "Current Balance"
        case .apr: return "Annual Percentage Rate"
        case .minimumPayment: return "Minimum Payment"
        case .minimumPaymentCalc: return "Minimum Payment Calculation"
        case .paymentFrequency: return "Payment Frequency"
        case .nextPaymentDate: return "Next Payment Due Date"
        case .notes: return "Notes"
        }
    }
}

// Add helper functions for payoff calculations
extension Debt {
    func calculatePayoffDate() -> Date {
        let balance = self.currentBalance - self.paidAmount
        let payment = self.minimumPayment
        let apr = self.apr / 100.0
        
        // Monthly interest rate
        let monthlyRate = apr / 12.0
        
        // Number of months needed to pay off debt
        // Using amortization formula: n = -log(1 - (r*PV)/PMT) / log(1 + r)
        // Where: r = monthly rate, PV = present value (balance), PMT = payment
        let monthsToPayoff: Double
        if monthlyRate > 0 {
            monthsToPayoff = -log(1 - (monthlyRate * balance) / payment) / log(1 + monthlyRate)
        } else {
            monthsToPayoff = balance / payment
        }
        
        // Calculate the payoff date
        return Calendar.current.date(byAdding: .month, value: Int(ceil(monthsToPayoff)), to: Date()) ?? Date()
    }
    
    func remainingTimeDescription() -> (months: Int, days: Int) {
        let payoffDate = calculatePayoffDate()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day], from: Date(), to: payoffDate)
        return (months: components.month ?? 0, days: components.day ?? 0)
    }
}

struct PayoffPoint: Identifiable {
    let id = UUID()
    let month: String
    let balance: Double
}

struct PaymentBreakdown: Identifiable {
    let id = UUID()
    let month: String
    let principal: Double
    let interest: Double
    let remainingBalance: Double
}

struct CostBreakdown: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    var color: Color
}

struct DebtDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var showEditModal = false
    @State private var editingField: EditableField?
    @ObservedObject var debt: Debt
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            /*HStack {
                Spacer()
                Text(debt.debtName ?? "Unknown")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .padding()
            .background(Color.white)*/

            
            // Tab Bar
            Picker("", selection: $selectedTab) {
                Text("Progress").tag(0)
                Text("Transactions").tag(1)
                Text("Details").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTab) {
                ProgressViewTab(debt: debt)
                    .tag(0)
                TransactionsView(debt: debt)
                    .tag(1)
                DetailsView(debt: debt, editingField: $editingField, showEditModal: $showEditModal)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .sheet(item: $editingField) { field in
            EditDetailView(
                debt: debt,
                field: field,
                showEditModal: $showEditModal,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
        .alert("Update Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

struct ProgressViewTab: View {
    let debt: Debt
    
    // Calculate monthly payoff points
    private var payoffPoints: [PayoffPoint] {
        var points: [PayoffPoint] = []
        let monthlyRate = debt.apr / (100.0 * 12.0)
        var currentBalance = debt.currentBalance - debt.paidAmount
        let payment = debt.minimumPayment
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        
        var currentDate = Date()
        
        // Generate points for each month until paid off
        while currentBalance > 0 {
            points.append(PayoffPoint(
                month: dateFormatter.string(from: currentDate),
                balance: currentBalance
            ))
            
            // Calculate next month's balance
            let interest = currentBalance * monthlyRate
            currentBalance = currentBalance + interest - payment
            
            // Move to next month
            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
            
            // Safety check to prevent infinite loop
            if points.count > 60 { // Show max 5 years
                break
            }
        }
        
        return points
    }
    
    // Calculate total interest and payments
    private func calculateTotalInterest() -> (principal: Double, interest: Double) {
        let balance = debt.currentBalance
        let payment = debt.minimumPayment
        let apr = debt.apr / 100.0
        
        var remainingBalance = balance
        var totalInterest: Double = 0
        
        while remainingBalance > 0 {
            let monthlyInterest = (remainingBalance * apr) / 12.0
            totalInterest += monthlyInterest
            
            let principalPayment = payment - monthlyInterest
            remainingBalance -= principalPayment
            
            // Break if payment is insufficient to cover interest
            if monthlyInterest >= payment {
                totalInterest = Double.infinity
                break
            }
            
            // Safety check to prevent infinite loop
            if totalInterest > balance * 10 {
                break
            }
        }
        
        return (principal: balance, interest: totalInterest)
    }
    
    // Calculate monthly payment breakdowns
    private func calculatePaymentBreakdowns() -> [PaymentBreakdown] {
        var breakdowns: [PaymentBreakdown] = []
        let monthlyPayment = debt.minimumPayment
        let monthlyRate = debt.apr / (100.0 * 12.0)
        var remainingBalance = debt.currentBalance
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        var currentDate = Date()
        
        // Generate first 12 months of payments
        for _ in 1...12 {
            let monthlyInterest = remainingBalance * monthlyRate
            let principalPayment = min(monthlyPayment - monthlyInterest, remainingBalance)
            
            if monthlyPayment <= monthlyInterest {
                break // Payment too low to make progress
            }
            
            breakdowns.append(PaymentBreakdown(
                month: dateFormatter.string(from: currentDate),
                principal: principalPayment,
                interest: monthlyInterest,
                remainingBalance: remainingBalance
            ))
            
            remainingBalance -= principalPayment
            if remainingBalance <= 0 { break }
            
            currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
        
        return breakdowns
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Updated Debt Payoff Date section
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("DEBT PAYOFF DATE")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(debt.calculatePayoffDate(), style: .date)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    let remainingTime = debt.remainingTimeDescription()
                    Text("\(remainingTime.months) months, \(remainingTime.days) days remaining")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                    
                    Text("Next Payment: \(debt.nextPaymentDate ?? Date(), style: .date)")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Payoff Progress section
                VStack(spacing: 20) {
                    Text("Payoff Progress")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let paidAmount = debt.paidAmount
                    let totalAmount = debt.currentBalance
                    let remainingAmount = totalAmount - paidAmount
                    
                    Chart {
                        SectorMark(
                            angle: .value("Paid", paidAmount),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .cornerRadius(3)
                        .foregroundStyle(Color("MainColor"))
                        
                        SectorMark(
                            angle: .value("Remaining", remainingAmount),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .cornerRadius(3)
                        .foregroundStyle(Color("MainColor").opacity(0.2))
                    }
                    .frame(height: 200)
                    .chartBackground { chartProxy in
                        GeometryReader { geometry in
                            let frame = geometry[chartProxy.plotFrame!]
                            VStack {
                                Text("\(Int((paidAmount/totalAmount) * 100))%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .position(
                                x: frame.midX,
                                y: frame.midY
                            )
                        }
                    }
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Principle Paid")
                            Spacer()
                            Text("LKR \(String(format: "%.2f", paidAmount))")
                                .foregroundColor(.green)
                        }
                        HStack {
                            Text("Balance")
                            Spacer()
                            Text("LKR \(String(format: "%.2f", remainingAmount))")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // New Cost Breakdown Section
                VStack(spacing: 20) {
                    Text("Cost Breakdown")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let breakdown = calculateTotalInterest()
                    let totalCost = breakdown.principal + breakdown.interest
                    
                    // Total Cost Row - Moved to the top
                    VStack(spacing: 4) {
                        Text("Total Cost")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("LKR \(String(format: "%.2f", totalCost))")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    
                    // Swift Charts Implementation
                    Chart {
                        SectorMark(
                            angle: .value("Amount", breakdown.principal),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color("MainColor"))
                        .cornerRadius(3)
                        
                        SectorMark(
                            angle: .value("Amount", breakdown.interest),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(Color.red.opacity(0.7))
                        .cornerRadius(3)
                    }
                    .frame(height: 200)
                    
                    // Breakdown Details
                    VStack(spacing: 15) {
                        // Principal Row
                        HStack {
                            HStack {
                                Circle()
                                    .fill(Color("MainColor"))
                                    .frame(width: 12, height: 12)
                                Text("Principal Amount")
                            }
                            Spacer()
                            Text("LKR \(String(format: "%.2f", breakdown.principal))")
                                .fontWeight(.medium)
                        }
                        
                        // Interest Row
                        HStack {
                            HStack {
                                Circle()
                                    .fill(Color.red.opacity(0.7))
                                    .frame(width: 12, height: 12)
                                Text("Total Interest")
                            }
                            Spacer()
                            Text("LKR \(String(format: "%.2f", breakdown.interest))")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Interest Insight
                    if breakdown.interest < Double.infinity {
                        Text("You'll pay \(String(format: "%.1f", (breakdown.interest / breakdown.principal) * 100))% of your principal in interest over the loan term.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                    } else {
                        Text("Warning: Your current payment is too low to fully pay off this debt. Consider increasing your payment amount.")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                
                // New Monthly Payment Breakdown Section
                VStack(spacing: 20) {
                    Text("Monthly Payment Breakdown")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let breakdowns = calculatePaymentBreakdowns()
                    
                    Chart {
                        ForEach(breakdowns) { breakdown in
                            BarMark(
                                x: .value("Month", breakdown.month),
                                y: .value("Amount", breakdown.principal),
                                stacking: .normalized
                            )
                            .foregroundStyle(Color("MainColor"))
                            
                            BarMark(
                                x: .value("Month", breakdown.month),
                                y: .value("Amount", breakdown.interest),
                                stacking: .normalized
                            )
                            .foregroundStyle(Color.red.opacity(0.7))
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks { value in
                            if let amount = value.as(Double.self) {
                                AxisValueLabel("LKR \(Int(amount))")
                            }
                        }
                    }
                    
                    // Legend
                    HStack(spacing: 20) {
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("MainColor"))
                                .frame(width: 20, height: 20)
                            Text("Principal")
                        }
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 20, height: 20)
                            Text("Interest")
                        }
                    }
                    
                    // Detailed Monthly Breakdown
                    VStack(spacing: 15) {
                        if let firstMonth = breakdowns.first {
                            Text("First Payment Breakdown")
                                .font(.subheadline)
                                .padding(.bottom, 5)
                            
                            // Principal Payment
                            HStack {
                                Text("Principal Payment")
                                Spacer()
                                Text("LKR \(String(format: "%.2f", firstMonth.principal))")
                                    .foregroundColor(Color("MainColor"))
                            }
                            
                            // Interest Payment
                            HStack {
                                Text("Interest Payment")
                                Spacer()
                                Text("LKR \(String(format: "%.2f", firstMonth.interest))")
                                    .foregroundColor(.red)
                            }
                            
                            Divider()
                            
                            // Total Payment
                            HStack {
                                Text("Total Monthly Payment")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("LKR \(String(format: "%.2f", firstMonth.principal + firstMonth.interest))")
                                    .fontWeight(.semibold)
                            }
                            
                            // Percentage Breakdown
                            Text("\(Int((firstMonth.principal / (firstMonth.principal + firstMonth.interest)) * 100))% goes to principal")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        }
                    }
                    .padding(.top)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // New Payoff Timeline section
                VStack(spacing: 20) {
                    Text("Payoff Timeline")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Chart {
                        ForEach(payoffPoints) { point in
                            LineMark(
                                x: .value("Month", point.month),
                                y: .value("Balance", point.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color("MainColor"))
                            
                            AreaMark(
                                x: .value("Month", point.month),
                                y: .value("Balance", point.balance)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color("MainColor").opacity(0.3),
                                        Color("MainColor").opacity(0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                    .frame(height: 200)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            if let balance = value.as(Double.self) {
                                AxisValueLabel("LKR \(String(format: "%.0f", balance))")
                            }
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            let month = value.as(String.self) ?? ""
                            if payoffPoints.count <= 12 || value.index % 3 == 0 {
                                AxisValueLabel(month)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}


struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isUpcomingSelected = true
    let debt: Debt // Add debt property to access the debt ID
    
    // Fetch requests for upcoming and past payments
    private var upcomingPayments: FetchRequest<Payment>
    private var pastPayments: FetchRequest<Payment>
    
    init(debt: Debt) {
        self.debt = debt
        
        // Safely handle the debtID
        let debtID = debt.debtID ?? UUID()
        
        // Initialize fetch request for upcoming payments
        self.upcomingPayments = FetchRequest<Payment>(
            entity: Payment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Payment.paymentDueDate, ascending: true)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "debtID == %@", debtID as CVarArg),
                NSPredicate(format: "status == %@", "upcoming")
            ])
        )
        
        // Initialize fetch request for past payments
        self.pastPayments = FetchRequest<Payment>(
            entity: Payment.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Payment.paymentDueDate, ascending: false)],
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "debtID == %@", debtID as CVarArg),
                NSPredicate(format: "status == %@", "completed")
            ])
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Tabs for Upcoming/Past
                HStack(spacing: 20) {
                    Button(action: {
                        isUpcomingSelected = true
                    }) {
                        Text("Upcoming")
                            .foregroundColor(isUpcomingSelected ? .blue : .gray)
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(isUpcomingSelected ? .blue : .clear),
                                alignment: .bottom
                            )
                    }
                    
                    Button(action: {
                        isUpcomingSelected = false
                    }) {
                        Text("Completed")
                            .foregroundColor(!isUpcomingSelected ? .blue : .gray)
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(!isUpcomingSelected ? .blue : .clear),
                                alignment: .bottom
                            )
                    }
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Content for Upcoming/Past
                if isUpcomingSelected {
                    // Upcoming Transactions Content
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upcoming Transactions")
                            .font(.headline)
                            .padding(.top)
                        
                        if upcomingPayments.wrappedValue.isEmpty {
                            Text("No upcoming payments")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(upcomingPayments.wrappedValue) { payment in
                                PaymentRowView(payment: payment, debt: debt)
                                Divider()
                            }
                        }
                    }
                    .padding()
                } else {
                    // Past Transactions Content
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Completed Transactions")
                            .font(.headline)
                            .padding(.top)
                        
                        if pastPayments.wrappedValue.isEmpty {
                            Text("No completed payments")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(pastPayments.wrappedValue) { payment in
                                PaymentRowView(payment: payment, isPast: true, debt: debt)
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

// Separate view for payment rows to keep the code organized
// Separate view for payment rows to keep the code organized
struct PaymentRowView: View {
    let payment: Payment
    var isPast: Bool = false
    @ObservedObject var debt: Debt
    
    // Calculate interest for upcoming payment
    private func calculateInterest() -> Double {
        let monthlyRate = debt.apr / (100.0 * 12.0)  // Convert annual rate to monthly
        return payment.balance * monthlyRate
    }
    
    var body: some View {
        HStack {
            // Status icon
            Image(systemName: isPast ? "checkmark.circle.fill" : "clock")
                .foregroundColor(isPast ? .green : .blue)
                .frame(width: 30, height: 30)
                .background(isPast ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                // Due date
                if let date = payment.paymentDueDate {
                    Text(date.formatted(date: .numeric, time: .omitted))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if isPast {
                    Text("LKR \(String(format: "%.2f", payment.amountPaid))")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                    
                    if let paidDate = payment.paidDate {
                        Text("Paid on \(paidDate.formatted(date: .numeric, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    // For upcoming payments, show principal and interest
                    let interest = calculateInterest()
                    let payaAmount = debt.minimumPayment + interest
                    
                    Text("LKR \(String(format: "%.2f", payaAmount))")
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("Interest: LKR \(String(format: "%.2f", interest))")
                        .font(.caption)
                        .foregroundColor(.blue)
                        
                    Text("Payment Due")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct DetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var debt: Debt
    @Binding var editingField: EditableField?
    @Binding var showEditModal: Bool
    @State private var showDeleteAlert = false
    @State private var deleteError: String? = nil
    @State private var showErrorAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Information Section
                GroupBox(label: Text("Information").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(title: "Debt Name", detail: debt.debtName ?? "Unknown", field: .debtName)
                        // Category is not editable
                        HStack {
                            Text("Category")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(debt.debtType ?? "Unknown")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        createNavigationLink(title: "Lending Institution", detail: debt.lenderName ?? "Unknown", field: .lenderName)
                    }
                }
                
                // Terms Section
                GroupBox(label: Text("Terms").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(
                            title: "Current Balance",
                            detail: "LKR \(String(format: "%.2f", debt.currentBalance))",
                            field: .currentBalance
                        )
                        createNavigationLink(
                            title: "Annual Percentage Rate",
                            detail: "\(String(format: "%.2f", debt.apr))%",
                            field: .apr
                        )
                    }
                }
                
                // Payment Details Section
                GroupBox(label: Text("Payment Details").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(
                            title: "Minimum Payment Calculation",
                            detail: debt.minimumPaymentCalc ?? "Unknown",
                            field: .minimumPaymentCalc
                        )
                        createNavigationLink(
                            title: "Minimum Payment",
                            detail: "LKR \(String(format: "%.2f", debt.minimumPayment))",
                            field: .minimumPayment
                        )
                        createNavigationLink(
                            title: "Payment Frequency",
                            detail: debt.paymentFrequency ?? "Unknown",
                            field: .paymentFrequency
                        )
                        createNavigationLink(
                            title: "Next Payment Due Date",
                            detail: debt.nextPaymentDate?.formatted(date: .long, time: .omitted) ?? "Unknown",
                            field: .nextPaymentDate
                        )
                    }
                }
                
                // Notes Section
                GroupBox(label: Text("Notes").font(.headline).foregroundColor(.primary)) {
                    Button(action: {
                        editingField = .notes
                        showEditModal = true
                    }) {
                        HStack {
                            if let notes = debt.notes, !notes.isEmpty {
                                Text(notes)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Add a note...")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Delete Button Section
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Delete Debt")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.top)
                .padding(.bottom)
            }
            .padding()
        }
        .alert("Delete Debt", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteDebtAndPayments()
            }
        } message: {
            Text("Are you sure you want to delete this debt? This action cannot be undone.")
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = deleteError {
                Text(error)
            }
        }
    }
    
    private func deleteDebtAndPayments() {
        // First, fetch all associated payments
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "debtID == %@", debt.debtID! as CVarArg)
        
        do {
            // Fetch all payments associated with this debt
            let payments = try viewContext.fetch(fetchRequest)
            
            // Delete each payment
            for payment in payments {
                viewContext.delete(payment)
            }
            
            // Delete the debt
            viewContext.delete(debt)
            
            // Save the context to persist the changes
            try viewContext.save()
            
            // Dismiss the view after successful deletion
            dismiss()
        } catch {
            print("Error deleting debt and payments: \(error)")
            deleteError = "Failed to delete debt: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
    
    private func createNavigationLink(title: String, detail: String, field: EditableField) -> some View {
        Button(action: {
            editingField = field
            showEditModal = true
        }) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Text(detail)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func deleteDebt() {
        viewContext.delete(debt)
        
        do {
            try viewContext.save()
            // Dismiss the view after successful deletion
            dismiss()
        } catch {
            print("Error deleting debt: \(error)")
        }
    }
}


struct EditDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var debt: Debt
    let field: EditableField
    @Binding var showEditModal: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    // State variables for different types of edits
    @State private var textInput: String = ""
    @State private var dateInput: Date = Date()
    @State private var numberInput: String = ""
    
    // State variables for pickers
    @State private var selectedPaymentCalc: String = ""
    @State private var selectedFrequency: String = ""
    
    // Constants for picker options
    let paymentCalcOptions = ["Fixed Amount", "Percentage of Balance"]
    let frequencyOptions = ["Monthly", "Bi-weekly", "Weekly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit \(field.title)")) {
                    switch field {
                    case .nextPaymentDate:
                        DatePicker("Select Date", selection: $dateInput, displayedComponents: .date)
                        
                    case .minimumPaymentCalc:
                        Picker(selection: $selectedPaymentCalc, label: Text("")) { // Empty label text
                            ForEach(paymentCalcOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .labelsHidden() // Hides any residual label spacing

                    case .paymentFrequency:
                        Picker(selection: $selectedFrequency, label: Text("")) { // Empty label text
                            ForEach(frequencyOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .labelsHidden() // Hides any residual label spacing

                        
                    case .currentBalance, .minimumPayment, .apr:
                        TextField("Enter value", text: $numberInput)
                            .keyboardType(.decimalPad)
                        
                    default:
                        TextField("Enter value", text: $textInput)
                    }
                }
            }
            .navigationBarTitle("Edit \(field.title)", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
            .onAppear {
                setupInitialValue()
            }
        }
    }
    
    private func setupInitialValue() {
        switch field {
        case .debtName:
            textInput = debt.debtName ?? ""
        case .lenderName:
            textInput = debt.lenderName ?? ""
        case .currentBalance:
            numberInput = String(format: "%.2f", debt.currentBalance)
        case .apr:
            numberInput = String(format: "%.2f", debt.apr)
        case .minimumPayment:
            numberInput = String(format: "%.2f", debt.minimumPayment)
        case .minimumPaymentCalc:
            selectedPaymentCalc = debt.minimumPaymentCalc ?? paymentCalcOptions[0]
        case .paymentFrequency:
            selectedFrequency = debt.paymentFrequency ?? frequencyOptions[0]
        case .nextPaymentDate:
            dateInput = debt.nextPaymentDate ?? Date()
        case .notes:
            textInput = debt.notes ?? ""
        }
    }
    
    private func saveChanges() {
        viewContext.performAndWait {
            switch field {
            case .debtName:
                debt.debtName = textInput
            case .lenderName:
                debt.lenderName = textInput
            case .currentBalance:
                if let value = Double(numberInput) {
                    debt.currentBalance = value
                }
            case .apr:
                if let value = Double(numberInput) {
                    debt.apr = value
                }
            case .minimumPayment:
                if let value = Double(numberInput) {
                    debt.minimumPayment = value
                }
            case .minimumPaymentCalc:
                debt.minimumPaymentCalc = selectedPaymentCalc
            case .paymentFrequency:
                debt.paymentFrequency = selectedFrequency
            case .nextPaymentDate:
                debt.nextPaymentDate = dateInput
            case .notes:
                debt.notes = textInput
            }
            
            do {
                try viewContext.save()
                alertMessage = "Successfully updated \(field.title.lowercased())"
                showAlert = true
                dismiss()
            } catch {
                alertMessage = "Failed to save changes: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

struct CarLoanView_Previews: PreviewProvider {
    static var previews: some View {
        //DebtDetailsView()
        EmptyView()
    }
}
