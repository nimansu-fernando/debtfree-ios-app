//
//  TrackingView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI

// MARK: - Models
struct DebtItem: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let balance: Double
    let totalDebtBalance: Double
    let dueDate: Date
    let isMinimum: Bool = true
    let isPaid: Bool
    
    // Init with default isPaid value for backward compatibility
    init(title: String, amount: Double, balance: Double, totalDebtBalance: Double, dueDate: Date, isPaid: Bool = false) {
        self.title = title
        self.amount = amount
        self.balance = balance
        self.totalDebtBalance = totalDebtBalance
        self.dueDate = dueDate
        self.isPaid = isPaid
    }
}

// MARK: - Main View
struct TrackingView: View {
    @State private var isUpcomingSelected = true
    
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
                    UpcomingView(octoberItems: octoberItems, novemberItems: novemberItems)
                } else {
                    CompletedView()
                }
            }
            .background(Color(UIColor.systemGray6))
        }
    }
    
    // Sample data for upcoming
    var octoberItems: [DebtItem] {
        [
            DebtItem(title: "Car",
                    amount: 80000.00,
                    balance: 2000000.00,
                    totalDebtBalance: 5000000.00,
                    dueDate: Date.from(year: 2024, month: 10, day: 23)),
            DebtItem(title: "Degree Loan",
                    amount: 40000.00,
                    balance: 600000.00,
                    totalDebtBalance: 800000.00,
                    dueDate: Date.from(year: 2024, month: 10, day: 29))
        ]
    }
    
    var novemberItems: [DebtItem] {
        [
            DebtItem(title: "Medical",
                    amount: 5000.00,
                    balance: 70000.00,
                    totalDebtBalance: 80000.00,
                    dueDate: Date.from(year: 2024, month: 11, day: 10)),
            DebtItem(title: "Car",
                    amount: 80000.00,
                    balance: 2000000.00,
                    totalDebtBalance: 5000000.00,
                    dueDate: Date.from(year: 2024, month: 11, day: 23))
        ]
    }
}

// MARK: - Upcoming View
struct UpcomingView: View {
    let octoberItems: [DebtItem]
    let novemberItems: [DebtItem]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                MonthSection(title: "October 2024 Remaining", items: octoberItems)
                MonthSection(title: "November 2024", items: novemberItems)
            }
            .padding()
        }
    }
}

// MARK: - Completed View
struct CompletedView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                MonthSection(title: "September 2024", items: septemberItems)
                MonthSection(title: "August 2024", items: augustItems)
            }
            .padding()
        }
    }
    
    // Sample data for completed transactions
    var septemberItems: [DebtItem] {
        [
            DebtItem(title: "Car",
                    amount: 80000.00,
                    balance: 2000000.00,
                    totalDebtBalance: 5000000.00,
                    dueDate: Date.from(year: 2024, month: 9, day: 23),
                    isPaid: true),
            DebtItem(title: "Degree Loan",
                    amount: 40000.00,
                    balance: 600000.00,
                    totalDebtBalance: 800000.00,
                    dueDate: Date.from(year: 2024, month: 9, day: 29),
                    isPaid: true)
        ]
    }
    
    var augustItems: [DebtItem] {
        [
            DebtItem(title: "Medical",
                    amount: 5000.00,
                    balance: 70000.00,
                    totalDebtBalance: 80000.00,
                    dueDate: Date.from(year: 2024, month: 8, day: 10),
                    isPaid: true),
            DebtItem(title: "Car",
                    amount: 80000.00,
                    balance: 2000000.00,
                    totalDebtBalance: 5000000.00,
                    dueDate: Date.from(year: 2024, month: 8, day: 23),
                    isPaid: true)
        ]
    }
}

// MARK: - Supporting Views
struct MonthSection: View {
    let title: String
    let items: [DebtItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(items) { item in
                    DebtItemView(item: item)
                    if item.id != items.last?.id {
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

struct DebtItemView: View {
    let item: DebtItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row - Title, Amount and Chevron
            HStack(spacing: 16) {
                // Clock icon
                Image(systemName: "clock")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                
                // Title and Amount
                HStack {
                    Text(item.title)
                        .font(.system(size: 18))
                    Spacer()
                    Text("LKR \(String(format: "%.2f", item.amount))")
                        .font(.system(size: 18))
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            
            // Balance Section
            HStack(spacing: 4) {
                Text("Balance ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("LKR \(String(format: "%.2f", item.balance))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 56)
            
            // Total Debt Balance Section
            HStack {
                Text("Total Debt Balance ")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Spacer()
                Text("LKR \(String(format: "%.2f", item.totalDebtBalance))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.leading, 56)
            
            // Date and Status Tag
            HStack {
                Text(item.dueDate.formatted(.custom("MMM dd, yyyy")))
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                if item.isPaid {
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
                    .background(Color.blue)
                    .cornerRadius(6)
                } else if item.isMinimum {
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
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
    }
}

// MARK: - Helpers
extension Date {
    static func from(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}

extension FormatStyle where Self == Date.FormatStyle {
    static func custom(_ format: String) -> Date.FormatStyle {
        Date.FormatStyle()
            .month(.abbreviated)
            .day(.twoDigits)
            .year(.defaultDigits)
    }
}

// MARK: - Preview
struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView()
    }
}
