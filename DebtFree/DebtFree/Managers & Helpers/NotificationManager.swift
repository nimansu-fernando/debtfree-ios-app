import Foundation
import UserNotifications
import CoreData
import SwiftUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        
        resetBadgeCount()
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func resetBadgeCount() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    func updateNotificationSettings(for type: NotificationItem.NotificationType, enabled: Bool, userID: String) {
        // Remove existing notifications of this type if disabled
        if !enabled {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                let identifiersToRemove = requests.filter { request in
                    switch type {
                    case .paymentDue:
                        return request.identifier.starts(with: "payment-due")
                    case .milestone:
                        return request.identifier.starts(with: "milestone")
                    case .highInterest:
                        return request.identifier.starts(with: "high-interest")
                    case .paymentOverdue:
                        return request.identifier.starts(with: "payment-overdue")
                    case .paymentSuccess:
                        return request.identifier.starts(with: "payment-success")
                    case .general:
                        return request.identifier.starts(with: "general")
                    }
                }.map { $0.identifier }
                
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
        } else {
            // If enabled reschedule relevant notifications
            let context = PersistenceController.shared.container.viewContext
            let request = NSFetchRequest<Debt>(entityName: "Debt")
            request.predicate = NSPredicate(format: "userID == %@", userID)
            
            do {
                let debts = try context.fetch(request)
                for debt in debts {
                    switch type {
                    case .paymentDue:
                        schedulePaymentDueNotifications(for: debt)
                    case .milestone:
                        let progress = debt.paidAmount / debt.currentBalance
                        scheduleMilestoneNotification(for: debt, progress: progress)
                    case .highInterest:
                        scheduleHighInterestNotification(for: debt)
                    default:
                        break
                    }
                }
            } catch {
                print("Error fetching debts for notification rescheduling: \(error)")
            }
        }
    }
    
    func schedulePaymentDueNotifications(for debt: Debt) {
        guard let userID = debt.userID,
              let debtName = debt.debtName,
              let nextPaymentDate = debt.nextPaymentDate,
              UserDefaults.standard.getNotificationSetting(for: .paymentDue, userID: userID) else {
            return
        }
        
        //payment is due tomorrow
        if isDateTomorrow(nextPaymentDate) {
            let content = UNMutableNotificationContent()
            content.title = "Payment Due Tomorrow!"
            content.body = "Payment of LKR \(String(format: "%.2f", debt.minimumPayment)) for \(debtName) is due tomorrow"
            content.sound = .default
            //content.badge = 1
            
            // Schedule for current time if payment is due tomorrow
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let identifier = "payment-due-tomorrow-\(debt.debtID?.uuidString ?? "")"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling tomorrow's due notification: \(error.localizedDescription)")
                }
            }
        }
        
        // notification intervals
        let intervals = [7, 4, 1]  // 1 week, 4 days, and 1 day before
        
        for daysBeforeDue in intervals {
            let notificationDate = Calendar.current.date(byAdding: .day, value: -daysBeforeDue, to: nextPaymentDate)!
            
            let content = UNMutableNotificationContent()
            content.title = "Payment Due in \(daysBeforeDue) day\(daysBeforeDue == 1 ? "" : "s")"
            content.body = "Payment of LKR \(String(format: "%.2f", debt.minimumPayment)) for \(debtName) is due on \(formatDate(nextPaymentDate))"
            content.sound = .default
            
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let identifier = "payment-due-\(daysBeforeDue)-\(debt.debtID?.uuidString ?? "")"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling payment due notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func isDateTomorrow(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        return calendar.isDate(date, inSameDayAs: tomorrow)
    }
    
    func scheduleMilestoneNotification(for debt: Debt, progress: Double) {
        guard let userID = debt.userID,
              let debtName = debt.debtName,
              UserDefaults.standard.getNotificationSetting(for: .milestone, userID: userID) else {
            return
        }
        
        // milestone percentages
        let milestones = [0.25, 0.5, 0.75, 1.0]
        
        // Find the current milestone
        if let currentMilestone = milestones.first(where: { abs($0 - progress) < 0.01 }) {
            let percentage = Int(currentMilestone * 100)
            
            let content = UNMutableNotificationContent()
            content.title = "🎉 Milestone Achievement!"
            content.body = "Congratulations! You've paid off \(percentage)% of your \(debtName)!"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let identifier = "milestone-\(percentage)-\(debt.debtID?.uuidString ?? "")"
            
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling milestone notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleHighInterestNotification(for debt: Debt) {
        guard let userID = debt.userID,
              let debtName = debt.debtName,
              debt.apr > 20,
              UserDefaults.standard.getNotificationSetting(for: .highInterest, userID: userID) else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ High Interest Alert"
        content.body = "\(debtName) has a high APR of \(String(format: "%.1f", debt.apr))%. Consider prioritizing this payment or exploring refinancing options."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "high-interest-\(debt.debtID?.uuidString ?? "")"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling high interest notification: \(error.localizedDescription)")
            }
        }
    }
    
    func removeScheduledNotifications(for debtID: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { request in
                request.identifier.contains(debtID.uuidString)
            }.map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    // UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
