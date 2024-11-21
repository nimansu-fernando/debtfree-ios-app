//
//  ProfileView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-07.
//

import SwiftUI
import FirebaseAuth
import LocalAuthentication

extension UserDefaults {
    enum NotificationKeys: String {
        case paymentDue = "notification_payment_due"
        case paymentOverdue = "notification_payment_overdue"
        case paymentSuccess = "notification_payment_success"
        case highInterest = "notification_high_interest"
        case milestone = "notification_milestone"
        case general = "notification_general"
        
        static var allCases: [NotificationKeys] {
            [.paymentDue, .paymentOverdue, .paymentSuccess, .highInterest, .milestone, .general]
        }
        
        func keyForUser(_ userID: String) -> String {
            return "\(userID)_\(self.rawValue)"
        }
    }
    
    func setNotificationSetting(_ value: Bool, for key: NotificationKeys, userID: String) {
        set(value, forKey: key.keyForUser(userID))
    }
    
    func getNotificationSetting(for key: NotificationKeys, userID: String) -> Bool {
        return bool(forKey: key.keyForUser(userID))
    }
}

struct NotificationSettingItem: Identifiable {
    let id = UUID()
    let type: NotificationItem.NotificationType
    let title: String
    let description: String
    let defaultKey: UserDefaults.NotificationKeys
}

struct ProfileView: View {
    @State private var isLoggedOut = false
    @State private var isFaceIDEnabled = false
    @State private var userName: String = ""
    @State private var userEmail: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @StateObject private var biometricManager = BiometricManager()
    @AppStorage ("use_faceid") private var useFaceID = false
    
    private func getUsernameFromEmail(_ email: String) -> String {
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex])
        }
        return email
    }
    
    private func loadUserData() {
        if let user = Auth.auth().currentUser {
            userEmail = user.email ?? ""
            userName = getUsernameFromEmail(userEmail)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color("MainColor"))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(userEmail)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Settings")) {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                    
                    NavigationLink(destination: FAQView()) {
                        Label("FAQ", systemImage: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: TermsAndConditionsView()) {
                        Label("Terms and Conditions", systemImage: "doc.text.fill")
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield.fill")
                    }
                }
                
                Section(header: Text("Security")) {
                    Toggle(isOn: $useFaceID) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.primary)
                            Text("Enable Face ID Login")
                                .foregroundColor(.primary)
                        }
                    }
                    .disabled(!biometricManager.isFaceIDAvailable)
                    .onChange(of: useFaceID) { newValue in
                        if newValue {
                            biometricManager.authenticateWithFaceID { success in
                                if !success {
                                    useFaceID = false
                                }
                            }
                        } else {
                            // Handle Face ID disabling
                            KeychainHelper.shared.delete(forKey: "userCredentials")
                            KeychainHelper.shared.delete(forKey: "lastLoggedInUser")
                            KeychainHelper.shared.delete(forKey: "uid")
                            UserDefaults.standard.removeObject(forKey: "use_faceid")
                            UserDefaults.standard.removeObject(forKey: "FaceIDEnabled")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                }
                
                Section {
                    Button(action: {
                        logOut()
                    }) {
                        Text("Log Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(25)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $isLoggedOut) {
                SignInView()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                loadUserData()
            }
        }
        .toolbar(.hidden, for: .tabBar)
    }
    
    func logOut() {
        do {
            if let user = Auth.auth().currentUser,
               let credentials = KeychainHelper.shared.getCredentials() {
                // Save current user's credentials before signing out
                KeychainHelper.shared.saveLastLoggedInUser(
                    email: credentials.email,
                    password: credentials.password
                )
            }
            
            try Auth.auth().signOut()
            KeychainHelper.shared.delete(forKey: "uid")
            UserDefaults.standard.removeObject(forKey: "FaceIDEnabled")
            // saving lastLoggedInUser credentials before logout
            self.isLoggedOut = true
        } catch let signOutError as NSError {
            alertMessage = "Error signing out: \(signOutError.localizedDescription)"
            showAlert = true
        }
    }
}

struct NotificationsSettingsView: View {
    @State private var userID: String
    
    private var isPaymentDueEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: .paymentDue, userID: userID) },
            set: { UserDefaults.standard.setNotificationSetting($0, for: .paymentDue, userID: userID) }
        )
    }
    
    private var isPaymentOverdueEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: .paymentOverdue, userID: userID) },
            set: { UserDefaults.standard.setNotificationSetting($0, for: .paymentOverdue, userID: userID) }
        )
    }
    
    private var isPaymentSuccessEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: .paymentSuccess, userID: userID) },
            set: { UserDefaults.standard.setNotificationSetting($0, for: .paymentSuccess, userID: userID) }
        )
    }
    
    private var isHighInterestEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: .highInterest, userID: userID) },
            set: { UserDefaults.standard.setNotificationSetting($0, for: .highInterest, userID: userID) }
        )
    }
    
    private var isMilestoneEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: .milestone, userID: userID) },
            set: { UserDefaults.standard.setNotificationSetting($0, for: .milestone, userID: userID) }
        )
    }
    
    private var isGeneralEnabled: Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: .general, userID: userID) },
            set: { UserDefaults.standard.setNotificationSetting($0, for: .general, userID: userID) }
        )
    }
    
    init() {
        self._userID = State(initialValue: Auth.auth().currentUser?.uid ?? "")
    }
    
    private let notificationSettings: [NotificationSettingItem] = [
        NotificationSettingItem(
            type: .paymentDue,
            title: "Payment Due Reminders",
            description: "Get notified when payments are approaching due date",
            defaultKey: .paymentDue
        ),
        //        NotificationSettingItem(
        //            type: .paymentOverdue,
        //            title: "Overdue Payments",
        //            description: "Get notified when payments are overdue",
        //            defaultKey: .paymentOverdue
        //        ),
        //        NotificationSettingItem(
        //            type: .paymentSuccess,
        //            title: "Payment Success",
        //            description: "Get notified when payments are successfully processed",
        //            defaultKey: .paymentSuccess
        //        ),
        NotificationSettingItem(
            type: .highInterest,
            title: "High Interest Alerts",
            description: "Get notified about debts with high interest rates",
            defaultKey: .highInterest
        ),
        NotificationSettingItem(
            type: .milestone,
            title: "Milestone Achievements",
            description: "Get notified when you reach payment milestones",
            defaultKey: .milestone
        )
    ]
    
    var body: some View {
        List {
            ForEach(notificationSettings) { setting in
                NotificationSettingRow(
                    title: setting.title,
                    description: setting.description,
                    isEnabled: binding(for: setting.defaultKey)
                )
            }
        }
        .navigationTitle("Notification Settings")
    }
    
    private func binding(for key: UserDefaults.NotificationKeys) -> Binding<Bool> {
        Binding(
            get: { UserDefaults.standard.getNotificationSetting(for: key, userID: userID) },
            set: { newValue in
                UserDefaults.standard.setNotificationSetting(newValue, for: key, userID: userID)
                // Update notification manager
                if let type = notificationTypeForKey(key) {
                    NotificationManager.shared.updateNotificationSettings(
                        for: type,
                        enabled: newValue,
                        userID: userID
                    )
                }
            }
        )
    }

    private func notificationTypeForKey(_ key: UserDefaults.NotificationKeys) -> NotificationItem.NotificationType? {
        switch key {
        case .paymentDue: return .paymentDue
        case .paymentOverdue: return .paymentOverdue
        case .paymentSuccess: return .paymentSuccess
        case .highInterest: return .highInterest
        case .milestone: return .milestone
        case .general: return .general
        }
    }
}

struct NotificationSettingRow: View {
    let title: String
    let description: String
    @Binding var isEnabled: Bool
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { isEnabled },
            set: { newValue in
                if newValue {
                    // Request notification permission when enabling
                    NotificationManager.shared.requestAuthorization { granted in
                        DispatchQueue.main.async {
                            if granted {
                                isEnabled = true
                            } else {
                                showingPermissionAlert = true
                            }
                        }
                    }
                } else {
                    isEnabled = false
                }
            }
        )) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color("MainColor")))
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("OK", role: .cancel) { }
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text("Please enable notifications in Settings to receive alerts.")
        }
    }
}

struct FAQView: View {
    var body: some View {
        List {
            Section(header: Text("Common Questions")) {
                Text("How do I add a new debt?")
                Text("How is progress calculated?")
                Text("Can I modify payment schedules?")
            }
        }
        .navigationTitle("FAQ")
    }
}

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            Text("The customer is very important, the customer will be followed by the customer...")
                .padding()
        }
        .navigationTitle("Terms & Conditions")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Your privacy is important to us...")
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
