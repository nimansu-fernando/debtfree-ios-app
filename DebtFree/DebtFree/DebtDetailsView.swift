//
//  DebtDetailsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI
import CoreData

// Move EditableField enum outside the view and make it conform to Identifiable
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
    
    // Required by Identifiable protocol
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

struct DebtDetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var showEditModal = false
    @State private var editingField: EditableField?
    @ObservedObject var debt: Debt
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Spacer()
                Text(debt.debtName ?? "Unknown")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            }
            .padding()
            .background(Color.white)

            
            // Tab Bar
            Picker("", selection: $selectedTab) {
                Text("Progress").tag(0)
                Text("Transactions").tag(1)
                Text("Details").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTab) {
                ProgressView(debt: debt)
                    .tag(0)
                TransactionsView()
                    .tag(1)
                DetailsView(debt: debt, editingField: $editingField, showEditModal: $showEditModal)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .sheet(item: $editingField) { field in
            EditDetailView(
                debt: debt,
                field: field,
                showEditModal: $showEditModal,
                showAlert: $showAlert,
                alertMessage: $alertMessage
            )
        }
        .alert("Update Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
}

struct ProgressView: View {
    let debt: Debt
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Debt Payoff Date
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("DEBT PAYOFF DATE")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text(debt.nextPaymentDate ?? Date(), style: .date)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    // Calculate days remaining...
                    Text("Payment Due")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Payoff Progress
                VStack(spacing: 20) {
                    Text("Payoff Progress")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let progress = debt.paidAmount / debt.currentBalance
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 15)
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(Color.blue, lineWidth: 15)
                            .rotationEffect(.degrees(-90))
                        Text("\(Int(progress * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(width: 100, height: 100)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Principle Paid")
                            Spacer()
                            Text("LKR \(String(format: "%.2f", debt.paidAmount))")
                                .foregroundColor(.green)
                        }
                        HStack {
                            Text("Balance")
                            Spacer()
                            Text("LKR \(String(format: "%.2f", debt.currentBalance - debt.paidAmount))")
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Payoff Timeline Chart
                VStack(alignment: .leading, spacing: 15) {
                    Text("Payoff Timeline")
                        .font(.headline)
                    
                    // Simple line chart representation
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 300, y: 150))
                    }
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(height: 200)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct TransactionsView: View {
    @State private var isUpcomingSelected = true // Track which tab is selected

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Tabs for Upcoming/Past
                HStack(spacing: 20) { // Adjust spacing to bring tabs closer
                    Button(action: {
                        isUpcomingSelected = true // Set upcoming tab as selected
                    }) {
                        Text("Upcoming")
                            .foregroundColor(isUpcomingSelected ? .blue : .gray) // Change color based on selection
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(isUpcomingSelected ? .blue : .clear), // Show underline if selected
                                alignment: .bottom
                            )
                    }
                    
                    Button(action: {
                        isUpcomingSelected = false // Set past tab as selected
                    }) {
                        Text("Past")
                            .foregroundColor(!isUpcomingSelected ? .blue : .gray) // Change color based on selection
                            .padding(.bottom, 8)
                            .overlay(
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(!isUpcomingSelected ? .blue : .clear), // Show underline if selected
                                alignment: .bottom
                            )
                    }
                }
                .padding(.leading) // Add leading padding for the tab bar
                .frame(maxWidth: .infinity, alignment: .leading) // Align HStack to the leading edge

                
                // Content for Upcoming/Past
                if isUpcomingSelected {
                    // Upcoming Transactions Content
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Upcoming Transactions")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(0..<4) { _ in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Nov 15, 2024")
                                
                                Spacer()
                                
                                Text("LKR 80,000.00")
                                    .fontWeight(.medium)
                            }
                            Divider()
                        }
                    }
                    .padding()
                } else {
                    // Past Transactions Content
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Past Transactions")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(0..<4) { _ in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Oct 15, 2024")
                                
                                Spacer()
                                
                                Text("LKR 70,000.00")
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                            }
                            Divider()
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct DetailsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var debt: Debt
    @Binding var editingField: EditableField?
    @Binding var showEditModal: Bool
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Information Section
                GroupBox(label: Text("Information").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(title: "Debt Name", detail: debt.debtName ?? "Unknown", field: .debtName)
                        // Category is not editable
                        HStack {
                            Text("Category")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(debt.debtType ?? "Unknown")
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        createNavigationLink(title: "Lending Institution", detail: debt.lenderName ?? "Unknown", field: .lenderName)
                    }
                }
                
                // Terms Section
                GroupBox(label: Text("Terms").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(
                            title: "Current Balance",
                            detail: "LKR \(String(format: "%.2f", debt.currentBalance))",
                            field: .currentBalance
                        )
                        createNavigationLink(
                            title: "Annual Percentage Rate",
                            detail: "\(String(format: "%.2f", debt.apr))%",
                            field: .apr
                        )
                    }
                }
                
                // Payment Details Section
                GroupBox(label: Text("Payment Details").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(
                            title: "Minimum Payment Calculation",
                            detail: debt.minimumPaymentCalc ?? "Unknown",
                            field: .minimumPaymentCalc
                        )
                        createNavigationLink(
                            title: "Minimum Payment",
                            detail: "LKR \(String(format: "%.2f", debt.minimumPayment))",
                            field: .minimumPayment
                        )
                        createNavigationLink(
                            title: "Payment Frequency",
                            detail: debt.paymentFrequency ?? "Unknown",
                            field: .paymentFrequency
                        )
                        createNavigationLink(
                            title: "Next Payment Due Date",
                            detail: debt.nextPaymentDate?.formatted(date: .long, time: .omitted) ?? "Unknown",
                            field: .nextPaymentDate
                        )
                    }
                }
                
                // Notes Section
                GroupBox(label: Text("Notes").font(.headline).foregroundColor(.primary)) {
                    Button(action: {
                        editingField = .notes
                        showEditModal = true
                    }) {
                        HStack {
                            if let notes = debt.notes, !notes.isEmpty {
                                Text(notes)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Add a note...")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Delete Button Section
                Button(action: {
                    showDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Delete Debt")
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.top)
                .padding(.bottom)
            }
            .padding()
        }
        .alert("Delete Debt", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteDebt()
            }
        } message: {
            Text("Are you sure you want to delete this debt? This action cannot be undone.")
        }
    }
    
    private func createNavigationLink(title: String, detail: String, field: EditableField) -> some View {
        Button(action: {
            editingField = field
            showEditModal = true
        }) {
            HStack {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                Text(detail)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
            }
            .padding(.vertical, 8)
        }
    }
    
    private func deleteDebt() {
        viewContext.delete(debt)
        
        do {
            try viewContext.save()
            // Dismiss the view after successful deletion
            dismiss()
        } catch {
            print("Error deleting debt: \(error)")
        }
    }
}


struct EditDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var debt: Debt
    let field: EditableField
    @Binding var showEditModal: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    // State variables for different types of edits
    @State private var textInput: String = ""
    @State private var dateInput: Date = Date()
    @State private var numberInput: String = ""
    
    // State variables for pickers
    @State private var selectedPaymentCalc: String = ""
    @State private var selectedFrequency: String = ""
    
    // Constants for picker options
    let paymentCalcOptions = ["Fixed Amount", "Percentage of Balance"]
    let frequencyOptions = ["Monthly", "Bi-weekly", "Weekly"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit \(field.title)")) {
                    switch field {
                    case .nextPaymentDate:
                        DatePicker("Select Date", selection: $dateInput, displayedComponents: .date)
                        
                    case .minimumPaymentCalc:
                        Picker(selection: $selectedPaymentCalc, label: Text("")) { // Empty label text
                            ForEach(paymentCalcOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .labelsHidden() // Hides any residual label spacing

                    case .paymentFrequency:
                        Picker(selection: $selectedFrequency, label: Text("")) { // Empty label text
                            ForEach(frequencyOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .labelsHidden() // Hides any residual label spacing

                        
                    case .currentBalance, .minimumPayment, .apr:
                        TextField("Enter value", text: $numberInput)
                            .keyboardType(.decimalPad)
                        
                    default:
                        TextField("Enter value", text: $textInput)
                    }
                }
            }
            .navigationBarTitle("Edit \(field.title)", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
            .onAppear {
                setupInitialValue()
            }
        }
    }
    
    private func setupInitialValue() {
        switch field {
        case .debtName:
            textInput = debt.debtName ?? ""
        case .lenderName:
            textInput = debt.lenderName ?? ""
        case .currentBalance:
            numberInput = String(format: "%.2f", debt.currentBalance)
        case .apr:
            numberInput = String(format: "%.2f", debt.apr)
        case .minimumPayment:
            numberInput = String(format: "%.2f", debt.minimumPayment)
        case .minimumPaymentCalc:
            selectedPaymentCalc = debt.minimumPaymentCalc ?? paymentCalcOptions[0]
        case .paymentFrequency:
            selectedFrequency = debt.paymentFrequency ?? frequencyOptions[0]
        case .nextPaymentDate:
            dateInput = debt.nextPaymentDate ?? Date()
        case .notes:
            textInput = debt.notes ?? ""
        }
    }
    
    private func saveChanges() {
        viewContext.performAndWait {
            switch field {
            case .debtName:
                debt.debtName = textInput
            case .lenderName:
                debt.lenderName = textInput
            case .currentBalance:
                if let value = Double(numberInput) {
                    debt.currentBalance = value
                }
            case .apr:
                if let value = Double(numberInput) {
                    debt.apr = value
                }
            case .minimumPayment:
                if let value = Double(numberInput) {
                    debt.minimumPayment = value
                }
            case .minimumPaymentCalc:
                debt.minimumPaymentCalc = selectedPaymentCalc
            case .paymentFrequency:
                debt.paymentFrequency = selectedFrequency
            case .nextPaymentDate:
                debt.nextPaymentDate = dateInput
            case .notes:
                debt.notes = textInput
            }
            
            do {
                try viewContext.save()
                alertMessage = "Successfully updated \(field.title.lowercased())"
                showAlert = true
                dismiss()
            } catch {
                alertMessage = "Failed to save changes: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}


struct CarLoanView_Previews: PreviewProvider {
    static var previews: some View {
        //DebtDetailsView()
        EmptyView()
    }
}
