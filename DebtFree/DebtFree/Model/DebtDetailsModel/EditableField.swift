//
//  EditableField.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation

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
