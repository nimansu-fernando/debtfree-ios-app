//
//  NotificationItem.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation
import SwiftUI

struct NotificationItem: Identifiable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let date: Date
    let relatedDebtID: UUID?
    
    enum NotificationType {
        case paymentDue
        case paymentOverdue
        case paymentSuccess
        case highInterest
        case milestone
        case general
        
        var icon: String {
            switch self {
            case .paymentDue: return "calendar.badge.exclamationmark"
            case .paymentOverdue: return "exclamationmark.circle.fill"
            case .paymentSuccess: return "checkmark.circle.fill"
            case .highInterest: return "chart.line.uptrend.xyaxis"
            case .milestone: return "star.fill"
            case .general: return "bell.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .paymentDue: return .orange
            case .paymentOverdue: return .red
            case .paymentSuccess: return .green
            case .highInterest: return .blue
            case .milestone: return .purple
            case .general: return Color("MainColor")
            }
        }
    }
}

