//
//  PaymentSection.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation

struct PaymentSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [Payment]
}
