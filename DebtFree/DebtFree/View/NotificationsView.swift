//
//  NotificationsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-18.
//

import Foundation
import SwiftUI
import CoreData
import FirebaseAuth

struct NotificationCenterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var debts: FetchedResults<Debt>
    @State private var notifications: [NotificationItem] = []
    @State private var selectedFilter: NotificationFilter = .all
    
    enum NotificationFilter: String, CaseIterable {
        case all = "All"
        case payments = "Payments"
        case milestones = "Milestones"
    }
    
    init() {
        let request: NSFetchRequest<Debt> = Debt.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Debt.nextPaymentDate, ascending: true)]
        request.predicate = NSPredicate(format: "userID == %@", Auth.auth().currentUser?.uid ?? "")
        _debts = FetchRequest(fetchRequest: request)
    }
    
    var filteredNotifications: [NotificationItem] {
        let userID = Auth.auth().currentUser?.uid ?? ""
        
        // First filter based on user specific notification preferences
        let notificationsBasedOnPreferences = notifications.filter { notification in
            switch notification.type {
            case .paymentDue:
                return UserDefaults.standard.getNotificationSetting(for: .paymentDue, userID: userID)
            case .paymentOverdue:
                return UserDefaults.standard.getNotificationSetting(for: .paymentOverdue, userID: userID)
            case .paymentSuccess:
                return UserDefaults.standard.getNotificationSetting(for: .paymentSuccess, userID: userID)
            case .highInterest:
                return UserDefaults.standard.getNotificationSetting(for: .highInterest, userID: userID)
            case .milestone:
                return UserDefaults.standard.getNotificationSetting(for: .milestone, userID: userID)
            case .general:
                return UserDefaults.standard.getNotificationSetting(for: .general, userID: userID)
            }
        }
        
        // Then filter based on selected category
        switch selectedFilter {
        case .all:
            return notificationsBasedOnPreferences
        case .payments:
            return notificationsBasedOnPreferences.filter { [.paymentDue, .paymentOverdue, .paymentSuccess].contains($0.type) }
        case .milestones:
            return notificationsBasedOnPreferences.filter { $0.type == .milestone }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NotificationFilter.allCases, id: \.self) { filter in
                        FilterTab(
                            title: filter.rawValue,
                            isSelected: filter == selectedFilter,
                            action: { selectedFilter = filter }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color.white)
            
            // Notifications List
            if filteredNotifications.isEmpty {
                EmptyNotificationView(filter: selectedFilter)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredNotifications) { notification in
                            NotificationCard(notification: notification)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemGray6))
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateNotifications()
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func generateNotifications() {
        var newNotifications: [NotificationItem] = []
        
        // Process each debt for notifications
        for debt in debts {
            // Payment Due Notifications
            if let nextPaymentDate = debt.nextPaymentDate {
                newNotifications.append(NotificationItem(
                    type: .paymentDue,
                    title: "Payment Due Soon",
                    message: "Payment of LKR \(String(format: "%.2f", debt.minimumPayment)) for \(debt.debtName ?? "your debt") is due on \(formatDate(nextPaymentDate)).",
                    date: Date(),
                    relatedDebtID: debt.debtID
                ))
            }
            
            // High Interest Alert
            if debt.apr > 20 {
                newNotifications.append(NotificationItem(
                    type: .highInterest,
                    title: "High Interest Alert",
                    message: "\(debt.debtName ?? "Your debt") has a high APR of \(String(format: "%.1f", debt.apr))%. Consider prioritizing this payment or looking for refinancing options.",
                    date: Date(),
                    relatedDebtID: debt.debtID
                ))
            }
            
            // Progress Milestones
            let progress = debt.paidAmount / debt.currentBalance
            if progress >= 0.5 && progress < 0.51 {  // 50% milestone
                newNotifications.append(NotificationItem(
                    type: .milestone,
                    title: "Milestone Achieved! 🎉",
                    message: "You've paid off 50% of your \(debt.debtName ?? "debt")! Keep up the great work!",
                    date: Date(),
                    relatedDebtID: debt.debtID
                ))
            }
        }
        
        notifications = newNotifications.sorted { $0.date > $1.date }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("MainColor") : Color(.systemGray6))
                .cornerRadius(20)
        }
    }
}

struct NotificationCard: View {
    let notification: NotificationItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: notification.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(notification.type.color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                    
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    //.lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 0.5)
    }
}

struct EmptyNotificationView: View {
    let filter: NotificationCenterView.NotificationFilter
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text(messageForFilter)
                .font(.headline)
            
            Text("Check back later for updates")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
    
    var messageForFilter: String {
        switch filter {
        case .all:
            return "No notifications yet"
        case .payments:
            return "No payment notifications"
        case .milestones:
            return "No milestone notifications"
        }
    }
}

struct NotificationCenterView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationCenterView()
    }
}
