//
//  TrackingView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import Foundation
import SwiftUI
import CoreData
import FirebaseAuth

struct TrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isUpcomingSelected = true
    @State private var userID: String = ""
    
    @FetchRequest private var upcomingPayments: FetchedResults<Payment>
    @FetchRequest private var completedPayments: FetchedResults<Payment>
    
    // Initialize with dynamic FetchRequest based on userID
    init() {
        // fetch request for upcoming payments
        let upcomingRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        upcomingRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Payment.paymentDueDate, ascending: true)]
        upcomingRequest.predicate = NSPredicate(format: "userID == %@ AND status == %@", "", "upcoming")
        _upcomingPayments = FetchRequest(fetchRequest: upcomingRequest)
        
        // fetch request for completed payments
        let completedRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        completedRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Payment.paymentDueDate, ascending: false)]
        completedRequest.predicate = NSPredicate(format: "userID == %@ AND status == %@", "", "completed")
        _completedPayments = FetchRequest(fetchRequest: completedRequest)
    }
    
    // properties for organizing payments into sections
    private var currentMonthPayments: [Payment] {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.startOfMonth(for: currentDate)
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        
        return upcomingPayments.filter { payment in
            guard let dueDate = payment.paymentDueDate else { return false }
            return dueDate >= currentMonth && dueDate < nextMonth
        }
    }
    
    private var nextMonthPayments: [Payment] {
        let currentDate = Date()
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: calendar.startOfMonth(for: currentDate))!
        let followingMonth = calendar.date(byAdding: .month, value: 1, to: nextMonth)!
        
        return upcomingPayments.filter { payment in
            guard let dueDate = payment.paymentDueDate else { return false }
            return dueDate >= nextMonth && dueDate < followingMonth
        }
    }
    
    private var next3MonthsPayments: [Payment] {
        let currentDate = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: 2, to: calendar.startOfMonth(for: currentDate))!
        let endDate = calendar.date(byAdding: .month, value: 5, to: calendar.startOfMonth(for: currentDate))!
        
        return upcomingPayments.filter { payment in
            guard let dueDate = payment.paymentDueDate else { return false }
            return dueDate >= startDate && dueDate < endDate
        }
    }
    
    private var upcomingSections: [PaymentSection] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        return [
            PaymentSection(
                title: "\(dateFormatter.string(from: Date())) Remaining",
                items: currentMonthPayments
            ),
            PaymentSection(
                title: dateFormatter.string(from: Calendar.current.date(byAdding: .month, value: 1, to: Date())!),
                items: nextMonthPayments
            ),
            PaymentSection(
                title: "Next 3 Months",
                items: next3MonthsPayments
            )
        ]
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tracking")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Record your transactions")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Tabs for Upcoming/Completed
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
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if isUpcomingSelected {
                    UpcomingPaymentsView(sections: upcomingSections)
                } else {
                    CompletedPaymentsView(payments: completedPayments)
                }
            }
            .background(Color(UIColor.systemGray6))
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.userID = user.uid
                    updateFetchRequests()
                }
            }
            .onChange(of: userID) { oldValue, newValue in
                updateFetchRequests()
            }
        }
    }
    
    private func updateFetchRequests() {
        upcomingPayments.nsPredicate = NSPredicate(format: "userID == %@ AND status == %@", userID, "upcoming")
        completedPayments.nsPredicate = NSPredicate(format: "userID == %@ AND status == %@", userID, "completed")
    }
}

struct UpcomingPaymentsView: View {
    let sections: [PaymentSection]
    
    private var hasNoData: Bool {
        sections.allSatisfy { $0.items.isEmpty }
    }
    
    var body: some View {
        ScrollView {
            if hasNoData {
                VStack {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    Text("No Upcoming Payments")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Text("When you add debts, your upcoming payments will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                VStack(spacing: 24) {
                    ForEach(sections) { section in
                        if !section.items.isEmpty {
                            MonthSection(title: section.title, items: section.items)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct CompletedPaymentsView: View {
    let payments: FetchedResults<Payment>
    
    private var paymentsByMonth: [(String, [Payment])] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        // Group payments by date string but keep track of the first date in each group
        var groupedWithDates: [(date: Date, key: String, payments: [Payment])] = []
        var tempGroups: [String: (date: Date, payments: [Payment])] = [:]
        
        for payment in payments {
            if let date = payment.paymentDueDate {
                let key = dateFormatter.string(from: date)
                
                if tempGroups[key] == nil {
                    tempGroups[key] = (date: date, payments: [])
                }
                tempGroups[key]?.payments.append(payment)
            }
        }
        
        // Convert dictionary to array and sort by actual date
        let sortedGroups = tempGroups.map { (key, value) in
            (date: value.date, key: key, payments: value.payments)
        }.sorted { $0.date < $1.date }
        
        // Convert back to the format we need for display
        return sortedGroups.map { (_, key, payments) in
            (key, payments)
        }
    }
    
    var body: some View {
        ScrollView {
            if payments.isEmpty {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding(.bottom, 8)
                    
                    Text("No Completed Payments")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                    
                    Text("Your payment history will appear here once you complete payments")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                VStack(spacing: 24) {
                    ForEach(paymentsByMonth, id: \.0) { month, monthPayments in
                        MonthSection(title: month, items: monthPayments)
                    }
                }
                .padding()
            }
        }
    }
}

struct MonthSection: View {
    let title: String
    let items: [Payment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(items) { payment in
                    PaymentItemView(payment: payment)
                    if payment.id != items.last?.id {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

struct PaymentDetailsSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let payment: Payment
    @State private var paymentAmount: Double
    @State private var paymentText: String
    @State private var debt: Debt?
    @State private var showingAlert = false
    @State private var showingConfirmation = false
    @State private var alertMessage = ""
    @State private var isCompleted = false
    
    init(payment: Payment) {
        self.payment = payment
        _paymentAmount = State(initialValue: 0.0)
        _paymentText = State(initialValue: String(format: "%.2f", 0.0))
    }
    
    private var monthlyInterestRate: Double {
        return (debt?.apr ?? 0) / 12.0 / 100.0
    }
    
    private var interestAccrued: Double {
        return payment.balance * monthlyInterestRate
    }
    
    private var totalAmount: Double {
        guard let debt = debt else { return 0.0 }
        return debt.minimumPayment + interestAccrued
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text(debt?.debtName ?? "Payment Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Planned Payment")
                        Spacer()
                        Text("Due Date")
                    }
                    .foregroundColor(.gray)
                    
                    HStack {
                        Text("LKR \(String(format: "%.2f", totalAmount))")
                            .fontWeight(.medium)
                        Spacer()
                        if let dueDate = payment.paymentDueDate {
                            Text(dueDate.formatted(.dateTime.day().month().year()))
                        }
                    }
                }
                .padding()
                .background(Color.white)
                
                // Payment Details Form
                VStack(spacing: 16) {
                    // Previous Balance
                    HStack {
                        Text("Previous Balance")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("LKR \(String(format: "%.2f", payment.balance))")
                    }
                    
                    // Interest Accrued
                    HStack {
                        Text("Interest Accrued")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("LKR \(String(format: "%.2f", interestAccrued))")
                    }
                    
                    if payment.status != "completed" {
                        // Payment Amount (Editable) - Only show for upcoming payments
                        HStack {
                            Text("Payment")
                                .foregroundColor(.gray)
                            Spacer()
                            HStack {
                                Text("LKR")
                                    .foregroundColor(.gray)
                                TextField("Enter amount", text: $paymentText)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 120)
                                    .onChange(of: paymentText) { oldValue, newValue in
                                        let filtered = newValue.filter { "0123456789.".contains($0) }
                                        if filtered != newValue {
                                            paymentText = filtered
                                        }
                                        if let amount = Double(filtered) {
                                            paymentAmount = amount
                                        }
                                    }
                            }
                        }
                    } else {
                        // Show paid amount for completed payments
                        HStack {
                            Text("Paid Amount")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("LKR \(String(format: "%.2f", payment.amountPaid))")
                        }
                    }
                    
                    Divider()
                    
                    // Total Payment
                    HStack {
                        Text(payment.status == "completed" ? "Total Paid" : "Total Payment")
                            .fontWeight(.medium)
                        Spacer()
                        Text("LKR \(String(format: "%.2f", payment.status == "completed" ? payment.amountPaid : paymentAmount))")
                            .fontWeight(.medium)
                    }
                    
                    if payment.status == "completed", let paidDate = payment.paidDate {
                        HStack {
                            Text("Paid Date")
                                .fontWeight(.medium)
                            Spacer()
                            Text(paidDate.formatted(.dateTime.day().month().year()))
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                
                Spacer()
                
                // Mark as Complete Button - Only show for upcoming payments
                if payment.status != "completed" {
                    Button(action: {
                        showingConfirmation = true
                    }) {
                        Text("Mark as Complete")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                    dismiss()
            })
            .alert("Confirm Payment", isPresented: $showingConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Confirm", role: .destructive) {
                    markAsComplete()
                }
            } message: {
                Text("Are you sure you want to mark this payment as complete? This action cannot be undone.")
            }
            .alert("Payment Update", isPresented: $showingAlert) {
                Button("OK") {
                    if isCompleted {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .interactiveDismissDisabled(isCompleted)
        }
        .onAppear {
            fetchDebtDetails()
            if payment.status != "completed" {
                paymentAmount = totalAmount
                paymentText = String(format: "%.2f", totalAmount)
            }
        }
    }
    
    private func fetchDebtDetails() {
        guard let debtID = payment.debtID else { return }
        
        let request: NSFetchRequest<Debt> = Debt.fetchRequest()
        request.predicate = NSPredicate(format: "debtID == %@", debtID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            self.debt = results.first
        } catch {
            print("Error fetching debt details: \(error)")
        }
    }
    
    private func markAsComplete() {
        guard let debt = debt else {
            alertMessage = "Error: Could not find associated debt"
            showingAlert = true
            return
        }
        
        if paymentAmount <= 0 {
            alertMessage = "Payment amount must be greater than zero"
            showingAlert = true
            return
        }
        
        // Calculate new total paid amount
        let newPaidAmount = debt.paidAmount + (paymentAmount - interestAccrued)
        
        // Calculate progress percentage before and after payment
        let oldProgress = debt.paidAmount / debt.currentBalance
        let newProgress = newPaidAmount / debt.currentBalance
        
        // Update Debt
        debt.paidAmount = newPaidAmount
        
        // Update Payment
        payment.amountPaid = paymentAmount
        payment.paidDate = Date()
        payment.status = "completed"
        
        // Check if we've crossed any milestone thresholds
        let milestones = [0.25, 0.50, 0.75, 1.0]
        let crossedMilestone = milestones.first { milestone in
            oldProgress < milestone && newProgress >= milestone
        }
        
        // Save changes to Core Data
        do {
            try viewContext.save()
            
            // Handle milestone notification if applicable
            if let milestone = crossedMilestone,
                let userID = debt.userID,
                UserDefaults.standard.getNotificationSetting(for: .milestone, userID: userID) {
                NotificationManager.shared.scheduleMilestoneNotification(for: debt, progress: milestone)
            }
            
            isCompleted = true
            alertMessage = "Payment marked as complete successfully"
            showingAlert = true
        } catch {
            print("Error saving context: \(error)")
            alertMessage = "Failed to update payment: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct PaymentItemView: View {
    let payment: Payment
    @Environment(\.managedObjectContext) private var viewContext
    @State private var debt: Debt?
    @State private var showingPaymentSheet = false
    
    // Interest calculations
    private var monthlyInterestRate: Double {
        guard let debt = debt else { return 0.0 }
        return (debt.apr / 12.0) / 100.0
    }
    
    private var calculatedInterest: Double {
        return payment.balance * monthlyInterestRate
    }
    
    private var totalAmount: Double {
        guard let debt = debt else { return 0.0 }
        return debt.minimumPayment + calculatedInterest
    }
    
    var body: some View {
        Button(action: {
            showingPaymentSheet = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: payment.status == "completed" ? "checkmark.circle.fill" : "clock")
                        .font(.system(size: 24))
                        .foregroundColor(payment.status == "completed" ? .green : .blue)
                        .frame(width: 40, height: 40)
                        .background(payment.status == "completed" ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    
                    // Payment Details
                    VStack(spacing: 8) {
                        HStack {
                            Text(debt?.debtName ?? "Unknown")
                                .foregroundColor(.black)
                                .font(.system(size: 18))
                            Spacer()
                            if payment.status == "completed" {
                                Text("LKR \(String(format: "%.2f", payment.amountPaid))")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            } else {
                                Text("LKR \(String(format: "%.2f", totalAmount))")
                                    .foregroundColor(.black)
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                            }
                        }
                        
                        // Show Interest only for upcoming payments
                        if payment.status != "completed" {
                            HStack {
                                Text("Interest")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("LKR \(String(format: "%.2f", calculatedInterest))")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                        .frame(height: 40)
                }
                
                if payment.status == "completed" {
                    // Only show paid date for completed payments
                    if let paidDate = payment.paidDate {
                        Text("Paid on \(paidDate.formatted(.dateTime.day().month().year()))")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                            .padding(.leading, 56)
                    }
                } else {
                    // Show due date only for upcoming payments
                    HStack {
                        if let dueDate = payment.paymentDueDate {
                            Text(dueDate.formatted(.dateTime.day().month().year()))
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Text("Minimum")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .cornerRadius(6)
                    }
                    .padding(.leading, 56)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showingPaymentSheet) {
            PaymentDetailsSheet(payment: payment)
        }
        .onAppear {
            fetchDebtDetails()
        }
    }
    
    private func fetchDebtDetails() {
        guard let debtID = payment.debtID else { return }
        
        let request: NSFetchRequest<Debt> = Debt.fetchRequest()
        request.predicate = NSPredicate(format: "debtID == %@", debtID as CVarArg)
        request.fetchLimit = 1
        
        do {
            let results = try viewContext.fetch(request)
            self.debt = results.first
        } catch {
            print("Error fetching debt details: \(error)")
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
}
