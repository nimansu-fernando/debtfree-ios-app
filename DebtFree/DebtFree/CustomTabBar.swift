//
//  CustomTabBar.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-06.
//

import SwiftUI

// Tab item model
struct TabBarItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

// Custom Tab Bar component
struct CustomTabBar: View {
    @State private var selectedTab = 0
    
    private let tabs: [TabBarItem] = [
        TabBarItem(icon: "house.fill", title: "Home"),
        TabBarItem(icon: "chart.pie.fill", title: "Debts"),
        TabBarItem(icon: "calendar", title: "Plan"),
        TabBarItem(icon: "banknote.fill", title: "Budget"),
        TabBarItem(icon: "chart.bar.fill", title: "Track")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .ignoresSafeArea(.all, edges: .bottom)
                    .tag(0)
                
                DebtView()
                    .ignoresSafeArea(.all, edges: .bottom)
                    .tag(1)
                
                PlanView()
                    .ignoresSafeArea(.all, edges: .bottom)
                    .tag(2)
                
                BudgetView()
                    .ignoresSafeArea(.all, edges: .bottom)
                    .tag(3)
                
                TrackingView()
                    .ignoresSafeArea(.all, edges: .bottom)
                    .tag(4)
            }
            
            // Tab Bar
            HStack {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24))
                        Text(tab.title)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(selectedTab == index ? Color("MainColor") : .gray)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(.easeIn(duration: 0.2)) {
                            selectedTab = index
                        }
                    }
                }
            }
            .frame(height: 100)
            .padding(.top, -5)
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.gray.opacity(0.2)),
                alignment: .top
            )
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ContentsView: View {
    var body: some View {
        CustomTabBar()
            .navigationBarHidden(true)
    }
}

// Preview
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar()
    }
}

