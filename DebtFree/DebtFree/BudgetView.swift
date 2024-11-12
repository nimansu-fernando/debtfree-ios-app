//
//  BudgetView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI
import Charts
import CoreData
import FirebaseAuth

class BudgetViewModel: ObservableObject {
    @Published var income: [NSManagedObject] = []
    @Published var savings: [NSManagedObject] = []
    @Published var expenses: [NSManagedObject] = []
    @Published var showingAddCategory = false
    @Published var selectedCategoryType: CategoryType?
    @Published var showingAlert = false
    @Published var alertMessage = ""
    private var managedObjectContext: NSManagedObjectContext
    private var userID: String
    
    enum CategoryType: String {
        case income = "Income"
        case savings = "Savings"
        case expenses = "Expenses"
    }
    
    init(context: NSManagedObjectContext, userID: String) {
        self.managedObjectContext = context
        self.userID = userID
        loadBudgetCategories()
    }
    
    var totalIncome: Double {
        income.reduce(0) { $0 + (($1.value(forKey: "amount") as? Double) ?? 0) }
    }
    
    var totalSavings: Double {
        savings.reduce(0) { $0 + (($1.value(forKey: "amount") as? Double) ?? 0) }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + (($1.value(forKey: "amount") as? Double) ?? 0) }
    }
    
    var remaining: Double {
        totalIncome - (totalSavings + totalExpenses)
    }
    
    func addCategory(name: String, icon: String, amount: Double, type: CategoryType) {
        let entity = NSEntityDescription.entity(forEntityName: "BudgetCategory", in: managedObjectContext)!
        let newCategory = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        
        newCategory.setValue(UUID(), forKey: "id")
        newCategory.setValue(name, forKey: "name")
        newCategory.setValue(icon, forKey: "icon")
        newCategory.setValue(amount, forKey: "amount")
        newCategory.setValue(type.rawValue, forKey: "type")
        newCategory.setValue(userID, forKey: "userID")
        
        saveContext()
        loadBudgetCategories()
    }
    
    func updateCategory(_ category: NSManagedObject, newAmount: Double) {
        category.setValue(newAmount, forKey: "amount")
        saveContext()
        loadBudgetCategories()
        validateBudget()
    }
    
    func deleteCategory(_ category: NSManagedObject) {
        managedObjectContext.delete(category)
        saveContext()
        loadBudgetCategories()
    }
    
    private func loadBudgetCategories() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "BudgetCategory")
        request.predicate = NSPredicate(format: "userID == %@", userID)
        
        do {
            let categories = try managedObjectContext.fetch(request)
            
            // Sort categories by type
            income = categories.filter { $0.value(forKey: "type") as? String == CategoryType.income.rawValue }
            savings = categories.filter { $0.value(forKey: "type") as? String == CategoryType.savings.rawValue }
            expenses = categories.filter { $0.value(forKey: "type") as? String == CategoryType.expenses.rawValue }
        } catch {
            print("Error fetching categories: \(error)")
        }
    }
    
    private func validateBudget() {
        if totalSavings + totalExpenses > totalIncome {
            showingAlert = true
            alertMessage = "Warning: Your expenses and savings exceed your income!"
        }
    }
    
    private func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}


struct BudgetView: View {
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject private var viewModel: BudgetViewModel
    
    init() {
        // Get current user ID from Firebase Auth
        let userID = Auth.auth().currentUser?.uid ?? ""
        // Initialize viewModel with managedObjectContext and userID
        _viewModel = StateObject(wrappedValue: BudgetViewModel(
            context: PersistenceController.shared.container.viewContext,
            userID: userID
        ))
    }
    
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
                    Text("LKR \(viewModel.remaining, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.remaining >= 0 ? .green : .red)
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
                        if viewModel.totalIncome > 0 {
                            SectorMark(
                                angle: .value("Savings", viewModel.totalSavings),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .cornerRadius(3)
                            .foregroundStyle(.mint)
                            
                            SectorMark(
                                angle: .value("Expenses", viewModel.totalExpenses),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .cornerRadius(3)
                            .foregroundStyle(.pink)
                            
                            SectorMark(
                                angle: .value("Remaining", max(0, viewModel.remaining)),
                                innerRadius: .ratio(0.6),
                                angularInset: 1.0
                            )
                            .cornerRadius(3)
                            .foregroundStyle(.blue)
                        }
                    }
                    .frame(height: 200)
                    
                    HStack(spacing: 20) {
                        legendItem(color: .mint, label: "Savings", value: viewModel.totalSavings)
                        legendItem(color: .pink, label: "Expenses", value: viewModel.totalExpenses)
                        legendItem(color: .blue, label: "Remaining", value: max(0, viewModel.remaining))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Categories Sections
                categorySection(
                    title: "Income",
                    categories: viewModel.income,
                    type: .income
                )
                
                categorySection(
                    title: "Savings",
                    categories: viewModel.savings,
                    type: .savings
                )
                
                categorySection(
                    title: "Expenses",
                    categories: viewModel.expenses,
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
        categories: [NSManagedObject],
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
                ForEach(categories, id: \.self) { category in  // Added id: \.self
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
    let category: NSManagedObject
    let type: BudgetViewModel.CategoryType
    @ObservedObject var viewModel: BudgetViewModel
    @State private var amount: String
    @State private var showingDeleteAlert = false
    
    init(category: NSManagedObject, type: BudgetViewModel.CategoryType, viewModel: BudgetViewModel) {
        self.category = category
        self.type = type
        self.viewModel = viewModel
        _amount = State(initialValue: String(format: "%.2f", category.value(forKey: "amount") as? Double ?? 0.0))
    }
    
    var body: some View {
        HStack {
            Image(systemName: category.value(forKey: "icon") as? String ?? "dollarsign.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 32, height: 32)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            Text(category.value(forKey: "name") as? String ?? "")
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
                            viewModel.updateCategory(category, newAmount: newAmount)
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
                viewModel.deleteCategory(category)
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

