//
//  CostBreakdown.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation
import SwiftUI

struct CostBreakdown: Identifiable {
    let id = UUID()
    let category: String
    let amount: Double
    var color: Color
}
