//
//  BudgetViewModel.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-19.
//

import Foundation
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
