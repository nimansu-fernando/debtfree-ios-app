//
//  DebtDetailsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-05.
//

import SwiftUI

struct DebtDetailsView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Text("Back")
                    .foregroundColor(.blue)
                
                Spacer()
                Text("Car")
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
                ProgressView()
                    .tag(0)
                TransactionsView()
                    .tag(1)
                DetailsView()
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

struct ProgressView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Debt Payoff Date
                VStack(alignment: .center, spacing: 8) { // Change alignment to .center
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        Text("DEBT PAYOFF DATE")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Center the HStack
                    
                    Text("January 15, 2025")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center) // Center text
                    
                    Text("in 2 months 28 days")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center) // Center text
                }
                .frame(maxWidth: .infinity, alignment: .center) // Center the inner VStack
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                
                // Payoff Progress
                VStack(spacing: 20) {
                    Text("Payoff Progress")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.2), lineWidth: 15)
                        Circle()
                            .trim(from: 0, to: 0.224)
                            .stroke(Color.blue, lineWidth: 15)
                            .rotationEffect(.degrees(-90))
                        Text("22.4%")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(width: 100, height: 100)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Principle Paid")
                            Spacer()
                            Text("LKR 1,000,037.98")
                                .foregroundColor(.green)
                        }
                        HStack {
                            Text("Balance")
                            Spacer()
                            Text("LKR 3,000,962.19")
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
    @State private var showEditModal = false
    @State private var detailToEdit: String = "" // To hold the detail being edited

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Information Section
                GroupBox(label: Text("Information").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(title: "Debt Name", detail: "Car")
                        createNavigationLink(title: "Category", detail: "Vehicle Loan")
                        createNavigationLink(title: "Lending Institution", detail: "MBSL")
                    }
                }
                
                // Terms Section
                GroupBox(label: Text("Terms").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(title: "Current Balance", detail: "LKR 5,000,000.00")
                        createNavigationLink(title: "Annual Percentage Rate", detail: "16.00 %")
                    }
                }
                
                // Payment Details Section
                GroupBox(label: Text("Payment Details").font(.headline).foregroundColor(.primary)) {
                    VStack(spacing: 10) {
                        createNavigationLink(title: "Minimum Payment Calculation", detail: "Fixed")
                        createNavigationLink(title: "Minimum Payment", detail: "LKR 80,000.00")
                        createNavigationLink(title: "Payment Frequency", detail: "Once per month")
                        createNavigationLink(title: "Next Payment Due Date", detail: "Nov 25, 2024")
                    }
                }
                
                // Notes Section
                GroupBox(label: Text("Notes").font(.headline).foregroundColor(.primary)) {
                    Button(action: {
                        // Action for adding a note
                    }) {
                        HStack {
                            Text("Add a note...")
                                .foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showEditModal) {
            EditDetailView(detail: $detailToEdit)
        }
    }
    
    // Helper function to create a NavigationLink with a title and detail
    private func createNavigationLink(title: String, detail: String) -> some View {
        Button(action: {
            detailToEdit = detail // Set the detail to edit
            showEditModal.toggle() // Show the modal
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
            .padding(.vertical, 8) // Adds vertical padding for better touch target
        }
    }
}

struct EditDetailView: View {
    @Binding var detail: String // Binding to the detail being edited
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Detail")) {
                    TextField("Detail", text: $detail)
                }
            }
            .navigationBarTitle("Edit Detail", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                // Action to save changes
            })
        }
    }
}


struct CarLoanView_Previews: PreviewProvider {
    static var previews: some View {
        DebtDetailsView()
    }
}
