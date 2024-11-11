//
//  BudgetView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI
import Charts

struct Budget: Codable {
    var income: [BudgetCategory]
    var savings: [BudgetCategory]
    var expenses: [BudgetCategory]
    
    var totalIncome: Double {
        income.reduce(0) { $0 + $1.amount }
    }
    
    var totalSavings: Double {
        savings.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var remaining: Double {
        totalIncome - (totalSavings + totalExpenses)
    }
}

struct BudgetCategory: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var amount: Double
    
    init(id: UUID = UUID(), name: String, icon: String, amount: Double) {
        self.id = id
        self.name = name
        self.icon = icon
        self.amount = amount
    }
}

class BudgetViewModel: ObservableObject {
    @Published var budget: Budget
    @Published var showingAddCategory = false
    @Published var selectedCategoryType: CategoryType?
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    enum CategoryType: String {
        case income = "Income"
        case savings = "Savings"
        case expenses = "Expenses"
    }
    
    init() {
        self.budget = Budget(
            income: [BudgetCategory(name: "Salary", icon: "dollarsign.circle.fill", amount: 0)],
            savings: [BudgetCategory(name: "Savings", icon: "banknote.fill", amount: 0)],
            expenses: []
        )
        loadBudget()
    }
    
    func addCategory(name: String, icon: String, amount: Double, type: CategoryType) {
        let newCategory = BudgetCategory(name: name, icon: icon, amount: amount)
        
        switch type {
        case .income:
            budget.income.append(newCategory)
        case .savings:
            budget.savings.append(newCategory)
        case .expenses:
            budget.expenses.append(newCategory)
        }
        
        saveBudget()
    }
    
    func updateCategory(_ category: BudgetCategory, newAmount: Double, type: CategoryType) {
        switch type {
        case .income:
            if let index = budget.income.firstIndex(where: { $0.id == category.id }) {
                budget.income[index].amount = newAmount
            }
        case .savings:
            if let index = budget.savings.firstIndex(where: { $0.id == category.id }) {
                budget.savings[index].amount = newAmount
            }
        case .expenses:
            if let index = budget.expenses.firstIndex(where: { $0.id == category.id }) {
                budget.expenses[index].amount = newAmount
            }
        }
        
        validateBudget()
        saveBudget()
    }
    
    func deleteCategory(_ category: BudgetCategory, type: CategoryType) {
        switch type {
        case .income:
            budget.income.removeAll { $0.id == category.id }
        case .savings:
            budget.savings.removeAll { $0.id == category.id }
        case .expenses:
            budget.expenses.removeAll { $0.id == category.id }
        }
        
        saveBudget()
    }
    
    private func validateBudget() {
        if budget.totalSavings + budget.totalExpenses > budget.totalIncome {
            showingAlert = true
            alertMessage = "Warning: Your expenses and savings exceed your income!"
        }
    }
    
    private func saveBudget() {
        if let encoded = try? JSONEncoder().encode(budget) {
            UserDefaults.standard.set(encoded, forKey: "budget")
        }
    }
    
    private func loadBudget() {
        if let data = UserDefaults.standard.data(forKey: "budget"),
           let decoded = try? JSONDecoder().decode(Budget.self, from: data) {
            budget = decoded
        }
    }
}

struct BudgetView: View {
    @StateObject private var viewModel = BudgetViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 20) {
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
                .padding(.top)
                
                // Budget Overview Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Balance for Debt Repayments")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("LKR \(viewModel.budget.remaining, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.budget.remaining >= 0 ? .green : .red)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Charts Section
                VStack(spacing: 20) {
                    Text("Distribution Overview")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Chart {
                        if viewModel.budget.totalIncome > 0 {
                            SectorMark(
                                angle: .value("Savings", viewModel.budget.totalSavings),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .cornerRadius(3)
                            .foregroundStyle(.mint)
                            
                            SectorMark(
                                angle: .value("Expenses", viewModel.budget.totalExpenses),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .cornerRadius(3)
                            .foregroundStyle(.pink)
                            
                            SectorMark(
                                angle: .value("Remaining", max(0, viewModel.budget.remaining)),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .cornerRadius(3)
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 200)
                    
                    HStack(spacing: 20) {
                        legendItem(color: .mint, label: "Savings", value: viewModel.budget.totalSavings)
                        legendItem(color: .pink, label: "Expenses", value: viewModel.budget.totalExpenses)
                        legendItem(color: .blue, label: "Remaining", value: max(0, viewModel.budget.remaining))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Categories Sections
                categorySection(
                    title: "Income",
                    categories: viewModel.budget.income,
                    type: .income
                )
                
                categorySection(
                    title: "Savings",
                    categories: viewModel.budget.savings,
                    type: .savings
                )
                
                categorySection(
                    title: "Expenses",
                    categories: viewModel.budget.expenses,
                    type: .expenses
                )
                Spacer()
                    //.frame(height: 100) // Increased padding to account for tab bar height + safe area
            }
        }
        .background(Color(.systemGray6))
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .alert("Budget Alert", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.alertMessage)
        }
        .sheet(isPresented: $viewModel.showingAddCategory) {
            if let categoryType = viewModel.selectedCategoryType {
                AddCategorySheet(viewModel: viewModel, categoryType: categoryType)
            }
        }
    }
    
    private func legendItem(color: Color, label: String, value: Double) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                Text("LKR \(value, specifier: "%.2f")")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func categorySection(
        title: String,
        categories: [BudgetCategory],
        type: BudgetViewModel.CategoryType
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            if categories.isEmpty {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(width: 32, height: 32)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                        
                        Text("No items added")
                            .foregroundColor(.gray)
                            .font(.body)
                        
                        Spacer()
                        
                        HStack {
                            Text("LKR")
                                .foregroundColor(.gray.opacity(0.3))
                            Text("0.00")
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            } else {
                ForEach(categories) { category in
                    CategoryItemView(
                        category: category,
                        type: type,
                        viewModel: viewModel
                    )
                }
            }
            
            Button {
                viewModel.selectedCategoryType = type
                viewModel.showingAddCategory = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add \(title)")
                }
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

struct CategoryItemView: View {
    let category: BudgetCategory
    let type: BudgetViewModel.CategoryType
    @ObservedObject var viewModel: BudgetViewModel
    @State private var amount: String
    @State private var showingDeleteAlert = false
    
    init(category: BudgetCategory, type: BudgetViewModel.CategoryType, viewModel: BudgetViewModel) {
        self.category = category
        self.type = type
        self.viewModel = viewModel
        _amount = State(initialValue: String(format: "%.2f", category.amount))
    }
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(category.name)
                .font(.body)
            
            Spacer()
            
            HStack {
                Text("LKR")
                    .foregroundColor(.blue)
                TextField("0.00", text: $amount)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { newValue in
                    if let newAmount = Double(newValue) {
                        viewModel.updateCategory(category, newAmount: newAmount, type: type)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            
            Button {
                showingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .alert("Delete Category", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                viewModel.deleteCategory(category, type: type)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this category?")
        }
    }
}

struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BudgetViewModel
    let categoryType: BudgetViewModel.CategoryType
    
    @State private var name = ""
    @State private var icon = "dollarsign.circle.fill"
    @State private var amount = ""
    
    private let icons = [
        "dollarsign.circle.fill",
        "banknote.fill",
        "cart.fill",
        "car.fill",
        "house.fill",
        "cross.case.fill",
        "creditcard.fill",
        "gift.fill",
        "bag.fill",
        "theatermasks.fill"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                    
                    Picker("Icon", selection: $icon) {
                        ForEach(icons, id: \.self) { icon in
                            Image(systemName: icon)
                                .tag(icon)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add \(categoryType.rawValue)")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    if let amountValue = Double(amount) {
                        viewModel.addCategory(
                            name: name,
                            icon: icon,
                            amount: amountValue,
                            type: categoryType
                        )
                        dismiss()
                    }
                }
                .disabled(name.isEmpty || amount.isEmpty)
            )
        }
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
        BudgetView()
    }
}
