//
//  AddDebtView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-02.
//

import SwiftUI
import CoreData
import FirebaseAuth
import EventKit

struct AddDebtView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    // Firebase user ID
    @State private var userID: String = ""
    
    // Debt properties
    @State private var showDebtTypeSheet = false
    @State private var debtType: String = ""
    @State private var debtName: String = ""
    @State private var lenderName: String = ""
    @State private var currentBalance: String = ""
    @State private var apr: String = ""
    @State private var minimumPaymentCalc: String = ""
    @State private var minimumPayment: String = ""
    @State private var paymentFrequency: String = ""
    @State private var nextPaymentDate: Date = Date()
    @State private var addReminders: Bool = false
    @State private var notes: String = ""
    
    // Alert states
    @State private var showingCalendarPermissionAlert = false
    @State private var showingEventSavedAlert = false
    @State private var showingErrorAlert = false
    @State private var showingSuccessAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // TYPE OF DEBT
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TYPE OF DEBT")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Debt Type")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showDebtTypeSheet.toggle()
                            }) {
                                HStack {
                                    Text(debtType.isEmpty ? "Select the debt type" : debtType)
                                        .foregroundColor(debtType.isEmpty ? .gray : .black)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .sheet(isPresented: $showDebtTypeSheet) {
                            DebtTypeSelectionView(selectedType: $debtType, isPresented: $showDebtTypeSheet)
                        }
                    }
                    
                    // INFORMATION
                    VStack(alignment: .leading, spacing: 8) {
                        Text("INFORMATION")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Debt Name")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("Enter a Name", text: $debtName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Name of Lending Institution")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                TextField("Enter a Name", text: $lenderName)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                    }
                    
                    // TERMS
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TERMS")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Current Balance")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                HStack {
                                    Text("LKR")
                                        .foregroundColor(.gray)
                                    TextField("0", text: $currentBalance)
                                        .keyboardType(.decimalPad)
                                }
                                .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Annual Percentage Rate (APR)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                HStack {
                                    TextField("0", text: $apr)
                                        .keyboardType(.decimalPad)
                                    Text("%")
                                        .foregroundColor(.gray)
                                }
                                .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                    }
                    
                    // PAYMENT DETAILS
                    VStack(alignment: .leading, spacing: 8) {
                        Text("PAYMENT DETAILS")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Minimum Payment Calculation")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Menu {
                                    Button("Fixed Amount") { minimumPaymentCalc = "Fixed Amount" }
                                    Button("Percentage of Balance") { minimumPaymentCalc = "Percentage of Balance" }
                                } label: {
                                    HStack {
                                        Text(minimumPaymentCalc.isEmpty ? "Select minimum payment calculation" : minimumPaymentCalc)
                                            .foregroundColor(minimumPaymentCalc.isEmpty ? .gray : .black)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Minimum Payment")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                HStack {
                                    Text("LKR")
                                        .foregroundColor(.gray)
                                    TextField("0", text: $minimumPayment)
                                        .keyboardType(.decimalPad)
                                }
                                .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Payment Frequency")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Menu {
                                    Button("Monthly") { paymentFrequency = "Monthly" }
                                    Button("Bi-weekly") { paymentFrequency = "Bi-weekly" }
                                    Button("Weekly") { paymentFrequency = "Weekly" }
                                } label: {
                                    HStack {
                                        Text(paymentFrequency.isEmpty ? "Select the payment frequency" : paymentFrequency)
                                            .foregroundColor(paymentFrequency.isEmpty ? .gray : .black)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Next Payment Due Date")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                DatePicker("", selection: $nextPaymentDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // SET PAYMENT REMINDERS
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SET PAYMENT REMINDERS")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        Toggle("Add Reminders to Calendar", isOn: $addReminders)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: addReminders) { newValue in
                                if newValue {
                                    requestCalendarAccess()
                                }
                            }
                        
                        if addReminders {
                            Text("Reminders will be set 2 days before the due date.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.leading)
                        }
                    }
                    
                    // NOTES
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTES (OPTIONAL)")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    // Add Debt Button
                    Button(action: {
                        addDebt()
                    }) {
                        Text("Add Debt")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("MainColor"))
                            .cornerRadius(25)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .alert("Calendar Permission Required", isPresented: $showingCalendarPermissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enable calendar access in Settings to add payment reminders.")
            }
            .alert("Event Added", isPresented: $showingEventSavedAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Payment reminders have been added to your calendar.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK", role: .cancel) {
                    if addReminders {
                        createCalendarEvent()
                    }
                    dismiss()
                }
            } message: {
                Text("Debt has been successfully created!")
            }
            .navigationTitle("Add a Debt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()
                }
                    .foregroundColor(Color("MainColor"))
            )
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.userID = user.uid
            }
        }
    }
    
    private func requestCalendarAccess() {
        EventKitManager.shared.requestAccess { granted in
            DispatchQueue.main.async {
                if !granted {
                    showingCalendarPermissionAlert = true
                }
            }
        }
    }
    
    private func createCalendarEvent() {
        guard addReminders else { return }
        
        EventKitManager.shared.requestAccess { granted in
            if granted {
                let endDate = nextPaymentDate.addingTimeInterval(3600) // Add 1 hour for end date
                
                // Create recurrence rule based on payment frequency
                let recurrenceRule: EKRecurrenceRule? = {
                    let calendar = Calendar.current
                    switch paymentFrequency.lowercased() {
                    case "monthly":
                        return EKRecurrenceRule(
                            recurrenceWith: .monthly,
                            interval: 1,
                            end: nil
                        )
                    case "bi-weekly":
                        return EKRecurrenceRule(
                            recurrenceWith: .daily,
                            interval: 14,
                            end: nil
                        )
                    case "weekly":
                        return EKRecurrenceRule(
                            recurrenceWith: .weekly,
                            interval: 1,
                            end: nil
                        )
                    default:
                        return nil
                    }
                }()
                
                // Prepare event data
                let title = "Payment Due: \(debtName)"
                let location = lenderName
                let eventNotes = """
                Debt Type: \(debtType)
                Amount Due: LKR \(minimumPayment)
                \(notes)
                """
                
                // Create and save event
                let eventStore = EKEventStore()
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.location = location
                event.startDate = nextPaymentDate
                event.endDate = endDate
                event.notes = eventNotes
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                // Add recurrence rule if available
                if let rule = recurrenceRule {
                    event.recurrenceRules = [rule]
                }
                
                // Add 2-day advance alert
                let alarm = EKAlarm(relativeOffset: -2 * 24 * 60 * 60) // 2 days in seconds
                event.addAlarm(alarm)
                
                do {
                    try eventStore.save(event, span: .futureEvents)
                    DispatchQueue.main.async {
                        showingEventSavedAlert = true
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        showingErrorAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    showingCalendarPermissionAlert = true
                }
            }
        }
    }
    
    // Function to add debt to Core Data and generate payments
    private func addDebt() {
        let newDebt = Debt(context: viewContext)
        
        // Generate a unique ID for the debt
        newDebt.debtID = UUID()
        newDebt.userID = userID
        newDebt.debtType = debtType.isEmpty ? nil : debtType
        newDebt.debtName = debtName.isEmpty ? nil : debtName
        newDebt.lenderName = lenderName.isEmpty ? nil : lenderName
        newDebt.currentBalance = Double(currentBalance) ?? 0.0
        newDebt.apr = Double(apr) ?? 0.0
        newDebt.minimumPaymentCalc = minimumPaymentCalc.isEmpty ? nil : minimumPaymentCalc
        newDebt.minimumPayment = Double(minimumPayment) ?? 0.0
        newDebt.paymentFrequency = paymentFrequency.isEmpty ? nil : paymentFrequency
        newDebt.nextPaymentDate = nextPaymentDate
        newDebt.addReminders = addReminders
        newDebt.notes = notes.isEmpty ? nil : notes
        newDebt.paidAmount = 0.0
        
        // Generate and save upcoming payments
        generateUpcomingPayments(for: newDebt)
        
        do {
            try viewContext.save()
            showingSuccessAlert = true
            
            if UserDefaults.standard.getNotificationSetting(for: .highInterest, userID: userID) {
                NotificationManager.shared.scheduleHighInterestNotification(for: newDebt)
            }
            
            // Schedule payment due notifications
            NotificationManager.shared.schedulePaymentDueNotifications(for: newDebt)
            
            // Schedule high interest notification if applicable
            NotificationManager.shared.scheduleHighInterestNotification(for: newDebt)
            
            // Initial milestone notification (0% progress)
            NotificationManager.shared.scheduleMilestoneNotification(for: newDebt, progress: 0.0)
            
            print("Debt and payments saved successfully with ID: \(newDebt.debtID?.uuidString ?? "unknown")")
        } catch {
            errorMessage = "Failed to save debt: \(error.localizedDescription)"
            showingErrorAlert = true
            print("Failed to save debt: \(error.localizedDescription)")
        }
        
        let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        if let applicationSupportURL = urls.first?.appendingPathComponent("Application Support") {
            print("Database URL: \(applicationSupportURL)")
        }
    }
    
    // Function to generate upcoming payments until debt is zero
    private func generateUpcomingPayments(for debt: Debt) {
        guard let debtID = debt.debtID,
              let frequency = debt.paymentFrequency,
              let startDate = debt.nextPaymentDate else {
            return
        }
        
        var currentBalance = debt.currentBalance - debt.paidAmount
        let minimumPayment = debt.minimumPayment
        var currentDate = startDate
        
        // Continue generating payments until balance is zero or very close to zero
        while currentBalance > 0.01 {
            let payment = Payment(context: viewContext)
            payment.paymentID = UUID()
            payment.userID = debt.userID
            payment.debtID = debtID
            
            // For the last payment use the remaining balance if it's less than minimum payment
            let paymentAmount = min(minimumPayment, currentBalance)
            payment.balance = currentBalance
            payment.amountPaid = 0.0
            payment.paymentDueDate = currentDate
            payment.status = "upcoming"
            payment.paidDate = nil
            
            // Update balance for next payment (subtract minimum payment without interest)
            currentBalance = currentBalance - paymentAmount
            
            // Calculate next payment date based on frequency
            currentDate = calculateNextPaymentDate(from: currentDate, frequency: frequency)
        }
    }
    
    // Helper function to calculate next payment date remains the same
    private func calculateNextPaymentDate(from date: Date, frequency: String) -> Date {
        let calendar = Calendar.current
        
        switch frequency.lowercased() {
        case "monthly":
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case "bi-weekly":
            return calendar.date(byAdding: .day, value: 14, to: date) ?? date
        case "weekly":
            return calendar.date(byAdding: .day, value: 7, to: date) ?? date
        default:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        }
    }
    
    // Updated helper function to fetch and print all saved Debt records
    private func fetchAndPrintAllDebts() {
        let fetchRequest: NSFetchRequest<Debt> = Debt.fetchRequest()
        
        do {
            let debts = try viewContext.fetch(fetchRequest)
            print("Fetched \(debts.count) Debt records:")
            for debt in debts {
                print("----")
                print("debtID: \(debt.debtID?.uuidString ?? "N/A")")
                print("userID: \(debt.userID ?? "N/A")")
                print("debtType: \(debt.debtType ?? "N/A")")
                print("debtName: \(debt.debtName ?? "N/A")")
                print("lenderName: \(debt.lenderName ?? "N/A")")
                print("currentBalance: \(debt.currentBalance)")
                print("apr: \(debt.apr)")
                print("minimumPaymentCalc: \(String(describing: debt.minimumPaymentCalc))")
                print("minimumPayment: \(debt.minimumPayment)")
                print("paymentFrequency: \(debt.paymentFrequency ?? "N/A")")
                print("nextPaymentDate: \(debt.nextPaymentDate ?? Date())")
                print("addReminders: \(debt.addReminders)")
                print("notes: \(debt.notes ?? "N/A")")
                print("paidAmount: \(debt.paidAmount)")
            }
        } catch {
            print("Failed to fetch debts: \(error.localizedDescription)")
        }
    }
    
    // Function to fetch and print all payments for debugging
    private func fetchAndPrintAllPayments() {
        let fetchRequest: NSFetchRequest<Payment> = Payment.fetchRequest()
        
        do {
            let payments = try viewContext.fetch(fetchRequest)
            print("Fetched \(payments.count) Payment records:")
            var totalToPayBack = 0.0
            
            for payment in payments {
                print("----")
                print("paymentID: \(payment.paymentID?.uuidString ?? "N/A")")
                print("userID: \(payment.userID ?? "N/A")")
                print("debtID: \(String(describing: payment.debtID))")
                print("balance: \(String(format: "%.2f", payment.balance))")
                print("amountPaid: \(String(format: "%.2f", payment.amountPaid))")
                print("paymentDueDate: \(payment.paymentDueDate?.formatted(date: .numeric, time: .omitted) ?? "N/A")")
                print("status: \(payment.status ?? "N/A")")
                
                totalToPayBack += payment.amountPaid
            }
            
            // Print summary
            print("\n=== Payment Schedule Summary ===")
            print("Total number of payments: \(payments.count)")
            print("Total to pay back: $\(String(format: "%.2f", totalToPayBack))")
            let originalDebt = Double(currentBalance) ?? 0.0
            let totalInterest = totalToPayBack - originalDebt
            print("Total interest: $\(String(format: "%.2f", totalInterest))")
            
        } catch {
            print("Failed to fetch payments: \(error.localizedDescription)")
        }
    }
}

struct DebtTypeSelectionView: View {
    @Binding var selectedType: String
    @Binding var isPresented: Bool
    
    let debtTypes: [(title: String, description: String, iconName: String)] = [
        (title: "Credit Card", description: "A card issued by a financial institution that allows you to make purchases on credit.", iconName: "creditcard.fill"),
        (title: "Vehicle Loan", description: "A loan for purchasing your vehicle. The vehicle serves as collateral until the loan is fully paid off.", iconName: "car.fill"),
        (title: "Student Loan", description: "A loan to cover your education expenses, such as tuition, housing, and other costs.", iconName: "book.fill"),
        (title: "Buy Now, Pay Later Installments", description: "A payment option that allows you to make a purchase immediately and pay for it in subsequent installments.", iconName: "cart.fill"),
        (title: "Medical Debt", description: "Debt incurred from medical expenses and healthcare costs.", iconName: "cross.fill"),
        (title: "Family or Friend Loan", description: "A loan you borrow from family or friends, often with flexible terms.", iconName: "person.2.fill"),
        (title: "Personal Loan", description: "An unsecured loan that can be used to meet a variety of your personal financial needs.", iconName: "person.fill"),
        (title: "Business Loan", description: "A loan you get for business purposes, such as startup loans, term loans, lines of credit, and SBA loans.", iconName: "briefcase.fill"),
        (title: "Peer to Peer (P2P) Loan", description: "A loan borrowed directly from individuals through online platforms.", iconName: "network"),
        (title: "Other", description: "Any other form of debt not specifically categorized here.", iconName: "ellipsis")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(debtTypes, id: \.title) { debtType in
                    Button(action: {
                        selectedType = debtType.title
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: debtType.iconName)
                            //.resizable()
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)
                                .foregroundColor(Color("MainColor"))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(debtType.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(debtType.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal) 
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Choose a type of Debt")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Back") {
                    isPresented = false
                }
                    .foregroundColor(.blue)
            )
        }
    }
}


struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

struct AddDebtView_Previews: PreviewProvider {
    static var previews: some View {
        AddDebtView()
    }
}
