//
//  DebtsView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-02.
//

import SwiftUI
import CoreData
import FirebaseAuth
import Charts

struct DebtChartData: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    var color: Color
}

struct BalanceChartView: View {
    let debts: FetchedResults<Debt>
    let byCategory: Bool // true for category view, false for individual debts
    
    // Computed property to get chart data based on the view type
    var chartData: [DebtChartData] {
        if byCategory {
            // Group debts by type and sum their balances
            var categoryData: [String: Double] = [:]
            for debt in debts {
                let category = debt.debtType ?? "Other"
                let balance = debt.currentBalance - debt.paidAmount
                categoryData[category, default: 0] += balance
            }
            
            // Convert to chart data with assigned colors
            return categoryData.map { category, amount in
                DebtChartData(
                    name: category,
                    amount: amount,
                    color: colorForCategory(category)
                )
            }.filter { $0.amount > 0 } // Only show categories with positive balance
        } else {
            // Individual debts
            return debts.map { debt in
                DebtChartData(
                    name: debt.debtName ?? "Unknown",
                    amount: debt.currentBalance - debt.paidAmount,
                    color: colorForCategory(debt.debtType ?? "Other")
                )
            }.filter { $0.amount > 0 }
        }
    }
    
    // Total balance
    var totalBalance: Double {
        chartData.reduce(0) { $0 + $1.amount }
    }
    
    // Dynamic font size based on number of items
    private var dynamicFontSize: CGFloat {
        let baseSize: CGFloat = 14
        let itemCount = CGFloat(chartData.count)
        let minimumSize: CGFloat = 10
        
        // Reduce font size as number of items increases
        let calculatedSize = baseSize - (itemCount - 3) * 1.5
        return max(calculatedSize, minimumSize)
    }
    
    var body: some View {
        if chartData.isEmpty {
            // Show placeholder when no data
            Text("No debts found")
                .foregroundColor(.gray)
                .frame(height: 170)
        } else {
            HStack(spacing: 32) {
                // Chart
                Chart {
                    ForEach(chartData) { item in
                        SectorMark(
                            angle: .value("Amount", item.amount),
                            innerRadius: .ratio(0.618), // Golden ratio for aesthetics
                            angularInset: 1.0
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(3)
                    }
                }
                .frame(width: 150, height: 150)
                .overlay {
                    VStack {
                        Text("LKR")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(String(format: "%.2f", totalBalance))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                    }
                }
                
                // Legend with dynamic font size
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(chartData) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.name)
                                    .font(.system(size: dynamicFontSize))
                                Text("LKR \(String(format: "%.2f", item.amount))")
                                    .font(.system(size: max(dynamicFontSize - 2, 8)))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .frame(maxHeight: 150)
            }
            .padding()
        }
    }
    
    // Function to assign consistent colors to debt categories
    func colorForCategory(_ category: String) -> Color {
        switch category {
        case "Credit Card":
            return .red
        case "Vehicle Loan":
            return .blue
        case "Student Loan":
            return .green
        case "Buy Now, Pay Later Installments":
            return .orange
        case "Medical Debt":
            return .purple
        case "Family or Friend Loan":
            return .pink
        case "Personal Loan":
            return .cyan
        case "Business Loan":
            return .indigo
        case "Peer to Peer (P2P) Loan":
            return .mint
        default:
            return .gray
        }
    }
}


struct DebtView: View {
    @State private var searchText = ""
    @State private var currentPage = 0
    @State private var isShowingAddDebtView = false
    @State private var userID: String = ""
    
    // Updated FetchRequest with a predicate for the current user
    @FetchRequest private var debts: FetchedResults<Debt>
    
    // Initialize with dynamic FetchRequest based on userID
    init() {
        let request: NSFetchRequest<Debt> = Debt.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Debt.debtName, ascending: true)]
        request.predicate = NSPredicate(format: "userID == %@", "")
        _debts = FetchRequest(fetchRequest: request)
    }
    
    // Filtered debts for the list only
    var filteredDebts: [Debt] {
        if searchText.isEmpty {
            return Array(debts)
        } else {
            return debts.filter { debt in
                debt.debtName?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Debts")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Plan, track and achieve your payoff goal")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Balance by Category / Debt card with unique headings and indicators
                    VStack(alignment: .leading, spacing: 10) {
                        Text(currentPage == 0 ? "Balance by Category" : "Balance by Debt")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        TabView(selection: $currentPage) {
                            // Pass the full debts to charts regardless of search
                            BalanceChartView(debts: debts, byCategory: true)
                                .tag(0)
                            BalanceChartView(debts: debts, byCategory: false)
                                .tag(1)
                        }
                        .frame(height: 170)
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        
                        // Custom indicator circles
                        HStack {
                            ForEach(0..<2) { index in
                                Circle()
                                    .fill(currentPage == index ? Color.blue : Color.gray)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.vertical)
                    .background(Color.white)
                    .mask(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .padding(.bottom, -12)
                    )
                    .padding(.top)

                    // Debts section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            // Show total count and filtered count when searching
                            if !searchText.isEmpty {
                                Text("Showing \(filteredDebts.count) of \(debts.count) debts")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Debts")
                                    .font(.headline)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingAddDebtView = true
                            }) {
                                Text("+ Add")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color("MainColor"))
                                    .cornerRadius(25)
                            }
                        }
                        
                        // Search bar
                        SearchBar(text: $searchText)
                        
                        // Filtered Debt cards
                        ForEach(filteredDebts, id: \.self) { debt in
                            NavigationLink(destination: DebtDetailsView(debt: debt)) {
                                DebtCard(debt: DebtList(
                                    name: debt.debtName ?? "Unknown",
                                    balance: (debt.currentBalance - debt.paidAmount),
                                    minimum: debt.minimumPayment,
                                    apr: debt.apr,
                                    progress: debt.paidAmount / debt.currentBalance
                                ))
                                .padding(.horizontal)
                            }
                        }
                        
                        // Show "No results" message when search yields no results
                        if filteredDebts.isEmpty && !searchText.isEmpty {
                            VStack(spacing: 8) {
                                Text("No matching debts found")
                                    .font(.headline)
                                Text("Try adjusting your search terms")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .padding(.top)
                }
            }
            .background(Color(.systemGray6))
            .sheet(isPresented: $isShowingAddDebtView) {
                AddDebtView()
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.userID = user.uid
                    updateFetchRequest()
                }
            }
            .onChange(of: userID) { newValue in
                updateFetchRequest()
            }
        }
    }
    
    private func updateFetchRequest() {
        debts.nsPredicate = NSPredicate(format: "userID == %@", userID)
    }
}

// Structs remain unchanged

struct DebtCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
}

struct DebtList {
    let name: String
    let balance: Double
    let minimum: Double
    let apr: Double
    let progress: Double
}

struct PieChartView: View {
    let debts: [DebtCategory]
    
    var total: Double {
        debts.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack(spacing: 32) {
            // Pie Chart
            ZStack {
                ForEach(debts) { debt in
                    PieSlice(
                        startAngle: .degrees(startAngle(for: debt)),
                        endAngle: .degrees(endAngle(for: debt))
                    )
                    .fill(debt.color)
                }
                Text("$\(String(format: "%.2f", total))")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.semibold)
            }
            .frame(width: 150, height: 150)
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                ForEach(debts) { debt in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(debt.color)
                            .frame(width: 12, height: 12)
                        Text(debt.name)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
    }
    
    func startAngle(for debt: DebtCategory) -> Double {
        let index = debts.firstIndex(where: { $0.id == debt.id }) ?? 0
        let previousTotal = debts[..<index].reduce(0) { $0 + $1.amount }
        return previousTotal / total * 360
    }
    
    func endAngle(for debt: DebtCategory) -> Double {
        let index = debts.firstIndex(where: { $0.id == debt.id }) ?? 0
        let previousTotal = debts[...index].reduce(0) { $0 + $1.amount }
        return previousTotal / total * 360
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center,
                   radius: radius,
                   startAngle: Angle(degrees: -90) + startAngle,
                   endAngle: Angle(degrees: -90) + endAngle,
                   clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct DebtCard: View {
    let debt: DebtList
    
    // Data for the donut chart
    private var chartData: [ProgressChartData] {
        [
            ProgressChartData(type: "Paid", value: debt.progress * 100),
            ProgressChartData(type: "Remaining", value: (1 - debt.progress) * 100)
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(debt.name)
                    .foregroundColor(.black)
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 24) {
                // Progress Chart
                Chart(chartData, id: \.type) { item in
                    SectorMark(
                        angle: .value("Progress", item.value),
                        innerRadius: .ratio(0.8),
                        angularInset: 1.0
                    )
                    .foregroundStyle(item.type == "Paid" ? Color("MainColor") : Color("MainColor").opacity(0.2))
                }
                .frame(width: 60, height: 60)
                .overlay {
                    Text("\(Int(debt.progress * 100))%")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                }
                
                /// Debt Details
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Balance")
                            .foregroundColor(.gray)
                        HStack(alignment: .firstTextBaseline, spacing: 0) {
                            Text("LKR ")
                                .foregroundColor(.black)
                                .font(.caption)
                                .bold()
                            Text(String(format: "%.2f", debt.balance))
                                .foregroundColor(.black)
                                .font(.headline)
                                .bold()
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Minimum")
                                .foregroundColor(.gray)
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                Text("LKR ")
                                    .foregroundColor(.black)
                                    .font(.caption)
                                    .bold()
                                Text(String(format: "%.2f", debt.minimum))
                                    .foregroundColor(.black)
                                    .font(.body)
                                    .bold()
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("APR")
                                .foregroundColor(.gray)
                            Text("\(String(format: "%.1f", debt.apr))%")
                                .foregroundColor(.black)
                                .font(.body)
                                .bold()
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.bottom)
    }
}

// Supporting struct for the progress chart data
struct ProgressChartData {
    let type: String
    let value: Double
}

struct DebtView_Previews: PreviewProvider {
    static var previews: some View {
        DebtView()
    }
}
