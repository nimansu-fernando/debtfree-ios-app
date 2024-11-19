//
//  PaymentBreakdown.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation

struct PaymentBreakdown: Identifiable {
    let id = UUID()
    let month: String
    let principal: Double
    let interest: Double
    let remainingBalance: Double
}
