//
//  BudgetView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI

struct BudgetView: View {
    // State for new category amounts
    @State private var salaryAmount: String = "0"
    @State private var savingsAmount: String = "0"
    @State private var foodAmount: String = "0"
    @State private var transportationAmount: String = "0"
    @State private var electricityAmount: String = "0"
    @State private var healthcareAmount: String = "0"
    
    // Sample data for the pie chart
    let distributionData = [
        DistributionItem(name: "Debt Payment", percentage: 0.25, color: Color.blue),
        DistributionItem(name: "Savings", percentage: 0.15, color: Color.mint),
        DistributionItem(name: "Expenses", percentage: 0.60, color: Color.pink)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // Header
                VStack(alignment: .leading, spacing: 0) {
                    Text("Budget")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Manage your income and expenses for debt repayment")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Income Distribution Overview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Income Distribution Overview")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 32) {
                        // Pie Chart
                        DistributionChart(items: distributionData)
                            .frame(width: 150, height: 150)
                        
                        // Legend
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(distributionData) { item in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(item.color)
                                        .frame(width: 12, height: 12)
                                    Text(item.name)
                                        .font(.subheadline)
                                }
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .mask(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .padding(.bottom, -12) // Extend the mask to include the full height
                )
                
                // Income Section
                CategorySection(
                    title: "Income",
                    items: [
                        CategoryItem(icon: "dollarsign.circle.fill", name: "Salary", amount: $salaryAmount)
                    ]
                )
                
                // Savings Section
                CategorySection(
                    title: "Savings",
                    items: [
                        CategoryItem(icon: "banknote.fill", name: "Savings", amount: $savingsAmount)
                    ]
                )
                
                // Expenses Section
                CategorySection(
                    title: "Expenses",
                    items: [
                        CategoryItem(icon: "cart.fill", name: "Food", amount: $foodAmount),
                        CategoryItem(icon: "car.fill", name: "Transportation", amount: $transportationAmount),
                        CategoryItem(icon: "bolt.fill", name: "Electricity", amount: $electricityAmount),
                        CategoryItem(icon: "cross.case.fill", name: "Healthcare", amount: $healthcareAmount)
                    ]
                )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6))
    }
}

// Supporting Views and Models
struct DistributionItem: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let color: Color
}

struct DistributionChart: View {
    let items: [DistributionItem]
    
    var body: some View {
        ZStack {
            ForEach(items.indices, id: \.self) { index in
                PieSlice(
                    startAngle: .degrees(startAngle(for: index)),
                    endAngle: .degrees(endAngle(for: index))
                )
                .fill(items[index].color)
            }
            Circle()
                .fill(.white)
                .frame(width: 60, height: 60)
        }
    }
    
    private func startAngle(for index: Int) -> Double {
        let previous = items[..<index].reduce(0) { $0 + $1.percentage }
        return previous * 360
    }
    
    private func endAngle(for index: Int) -> Double {
        let previous = items[..<(index + 1)].reduce(0) { $0 + $1.percentage }
        return previous * 360
    }
}

struct CategorySection: View {
    let title: String
    let items: [CategoryItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                ForEach(items) { item in
                    CategoryItemView(item: item)
                }
                
                AddCategoryButton()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

struct CategoryItem: Identifiable {
    let id = UUID()
    let icon: String
    let name: String
    var amount: Binding<String>
}

struct CategoryItemView: View {
    let item: CategoryItem
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(item.name)
                .font(.body)
            
            Spacer()
            
            HStack {
                Text("LKR")
                    .foregroundColor(.blue)
                TextField("0", text: item.amount)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

struct AddCategoryButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Category")
            }
            .foregroundColor(.blue)
            .font(.body)
        }
    }
}

// Preview
struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
    }
}
