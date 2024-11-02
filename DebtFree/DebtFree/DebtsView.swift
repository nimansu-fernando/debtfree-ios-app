//
//  DebtsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-02.
//

import SwiftUI

// Debts View (Debts Page)
struct DebtsView: View {
    @State private var searchText = ""
    @State private var showingAddDebtView = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Header
                Text("Debts")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                Text("Plan, track and achieve your payoff goal")
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                
                // Balance by Category (Placeholder for Pie Chart)
                PieChartView() // Custom component to display chart
                    .frame(height: 200)
                    .padding(.horizontal)
                
                // Search bar
                HStack {
                    TextField("Search", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    
                    Button(action: {
                        showingAddDebtView.toggle()
                    }) {
                        Label("Add", systemImage: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $showingAddDebtView) {
                        AddDebtView()
                    }
                }
                .padding(.horizontal)
                
                // Debt list
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(0..<5) { _ in // Replace with your data array
                            DebtCardView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

// Preview for DebtsView
struct DebtsView_Previews: PreviewProvider {
    static var previews: some View {
        DebtsView()
    }
}

// Placeholder for Debt Card
struct DebtCardView: View {
    var body: some View {
        HStack {
            Circle()
                .trim(from: 0.0, to: 0.22) // Represents percentage
                .stroke(Color.blue, lineWidth: 6)
                .frame(width: 50, height: 50)
                .overlay(
                    Text("22.4%")
                        .font(.caption)
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading) {
                Text("Car")
                    .font(.headline)
                
                Text("Balance")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                Text("LKR 448,037.98")
                    .font(.subheadline)
                
                Text("Minimum")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                
                Text("LKR 80,000.00")
                    .font(.subheadline)
                
                Text("APR 16.00%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Preview for DebtCardView
struct DebtCardView_Previews: PreviewProvider {
    static var previews: some View {
        DebtCardView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

// Placeholder for Pie Chart
struct PieChartView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.3))
            
            Text("165,962.19")
                .font(.largeTitle)
        }
    }
}

// Add Debt View (Add Debt Page)
struct AddDebtView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var debtType = ""
    @State private var debtName = ""
    @State private var lenderName = ""
    @State private var currentBalance = ""
    @State private var apr = ""
    @State private var minimumPaymentCalculation = ""
    @State private var minimumPayment = ""
    @State private var paymentFrequency = ""
    @State private var paymentDueDate = Date()
    @State private var addReminder = false
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Type of Debt
                    Text("TYPE OF DEBT")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Select the debt type", text: $debtType)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Information
                    Text("INFORMATION")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Enter a Name", text: $debtName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    TextField("Enter a Name", text: $lenderName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Terms
                    Text("TERMS")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("LKR 0", text: $currentBalance)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    TextField("0%", text: $apr)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Payment Details
                    Text("PAYMENT DETAILS")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("Select the minimum payment calculation", text: $minimumPaymentCalculation)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    TextField("LKR 0", text: $minimumPayment)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    TextField("Select the payment frequency", text: $paymentFrequency)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    DatePicker("Select the payment due date", selection: $paymentDueDate, displayedComponents: .date)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Reminders
                    Text("SET PAYMENT REMINDERS")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Toggle("Add Reminders to Calendar", isOn: $addReminder)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Notes
                    Text("NOTES (OPTIONAL)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    TextField("", text: $notes)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Add Debt Button
                    Button(action: {
                        // Action to add debt
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Add Debt")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            .navigationBarTitle("Add a Debt", displayMode: .inline)
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Preview for AddDebtView
struct AddDebtView_Previews: PreviewProvider {
    static var previews: some View {
        AddDebtView()
    }
}
