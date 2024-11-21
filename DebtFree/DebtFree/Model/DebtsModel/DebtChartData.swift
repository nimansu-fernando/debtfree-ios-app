//
//  DebtChartData.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation
import SwiftUI

struct DebtChartData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    var color: Color
}
