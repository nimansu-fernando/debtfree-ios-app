//
//  CustomTabBar.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-06.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            DebtView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Debts", systemImage: "chart.pie.fill")
                }
                .tag(1)
            
            PlanView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
                .tag(2)
            
            BudgetView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Budget", systemImage: "banknote.fill")
                }
                .tag(3)
            
            TrackingView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("Track", systemImage: "chart.bar.fill")
                }
                .tag(4)
        }
        .tint(Color("MainColor")) // This will color the selected tab items
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

// Preview
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
