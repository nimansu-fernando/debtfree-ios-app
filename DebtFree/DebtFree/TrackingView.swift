//
//  TrackingView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI
import CoreData
import FirebaseAuth

struct PaymentSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [Payment]
}

struct TrackingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isUpcomingSelected = true
    @State private var userID: String = ""
    
    // Fetch requests for payments
    @FetchRequest private var upcomingPayments: FetchedResults<Payment>
    @FetchRequest private var completedPayments: FetchedResults<Payment>
    
    // Initialize with dynamic FetchRequest based on userID
    init() {
        // Initial fetch request for upcoming payments
        let upcomingRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        upcomingRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Payment.paymentDueDate, ascending: true)]
        upcomingRequest.predicate = NSPredicate(format: "userID == %@ AND status == %@", "", "upcoming")
        _upcomingPayments = FetchRequest(fetchRequest: upcomingRequest)
        
        // Initial fetch request for completed payments
        let completedRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        completedRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Payment.paymentDueDate, ascending: false)]
        completedRequest.predicate = NSPredicate(format: "userID == %@ AND status == %@", "", "completed")
        _completedPayments = FetchRequest(fetchRequest: completedRequest)
    }
    
    // Computed properties for organizing payments into sections
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
                // Custom Navigation Bar
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
                
                // Content
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
    
    var body: some View {
        ScrollView {
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

struct CompletedPaymentsView: View {
    let payments: FetchedResults<Payment>
    
    private var paymentsByMonth: [String: [Payment]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        
        var grouped: [String: [Payment]] = [:]
        for payment in payments {
            if let date = payment.paymentDueDate {
                let key = dateFormatter.string(from: date)
                if grouped[key] == nil {
                    grouped[key] = []
                }
                grouped[key]?.append(payment)
            }
        }
        return grouped
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(Array(paymentsByMonth.keys.sorted().reversed()), id: \.self) { month in
                    if let monthPayments = paymentsByMonth[month] {
                        MonthSection(title: month, items: monthPayments)
                    }
                }
            }
            .padding()
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

struct PaymentItemView: View {
    let payment: Payment
    @Environment(\.managedObjectContext) private var viewContext
    @State private var debt: Debt?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row - Title, Amount and Chevron
            HStack(spacing: 16) {
                // Clock icon
                Image(systemName: payment.status == "completed" ? "checkmark.circle.fill" : "clock")
                    .font(.system(size: 24))
                    .foregroundColor(payment.status == "completed" ? .green : .blue)
                    .frame(width: 40, height: 40)
                    .background(payment.status == "completed" ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                // Title and Amount
                HStack {
                    Text(debt?.debtName ?? "Unknown")
                        .font(.system(size: 18))
                    Spacer()
                    Text("LKR \(String(format: "%.2f", payment.balance))")
                        .font(.system(size: 18))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            // Payment Date and Status
            HStack {
                if let dueDate = payment.paymentDueDate {
                    Text(dueDate.formatted(.dateTime.day().month().year()))
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                if payment.status == "completed" {
                    // PAID tag with checkmark
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("PAID")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(6)
                } else {
                    Text("Minimum")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
            }
            .padding(.leading, 56)
            
            // Show paid date for completed payments
            if payment.status == "completed", let paidDate = payment.paidDate {
                Text("Paid on \(paidDate.formatted(.dateTime.day().month().year()))")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
                    .padding(.leading, 56)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
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

// Helper extension for date calculations
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
