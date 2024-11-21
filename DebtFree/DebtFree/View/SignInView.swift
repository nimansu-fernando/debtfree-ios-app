//
//  SignInView.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-10-27.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

struct SignInView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isSignedIn = false
    @State private var userName = ""
    @State private var isLoading = false
    
    // Email validation state
    @State private var isEmailValid = false
    
    @StateObject private var biometricManager = BiometricManager()
    @AppStorage ("use_faceid") private var useFaceID = false
    
    
    // Check if user session is active on view appear
    init() {
        if let _ = KeychainHelper.shared.get(forKey: "uid") {
            _isSignedIn = State(initialValue: true)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    Color("AccentColor1")
                        .frame(height: 175)
                    Color.white
                }
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image("DebtFreeLogo2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 257.62, height: 100)
                    
                    Text("Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 15)
                    
                    Text("Welcome to DebtFree!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, -15)
                    
                    // Apple Sign-In
                    Button(action: {}) {
                        HStack {
                            Image("apple-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Continue with Apple")
                                .foregroundColor(.white)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(25)
                    }
                    .disabled(isLoading)
                    .padding(.top, 20)
                    
                    // Google Sign-In Button
                    Button(action: signInWithGoogle) {
                        HStack {
                            Image("google-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            Text("Continue with Google")
                                .foregroundColor(.black)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .disabled(isLoading)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                        Text("or")
                            .foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    
                    // Email field with validation
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                        .onChange(of: email) { _ in
                            isEmailValid = isValidEmail(email)
                        }
                    
                    // Password Field with toggle
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).stroke(Color("MainColor"), lineWidth: 1))
                    
                    // Forgot Password Button
                    NavigationLink(destination: ForgotPasswordView()) {
                        HStack {
                            Spacer()
                            Text("Forgot Password?")
                                .foregroundColor(Color("SubColor"))
                        }
                    }
                    .padding(.top, 10)
                    
                    if biometricManager.isFaceIDAvailable && useFaceID  {
                        // Sign In Button and Face ID Row
                        HStack(spacing: 15) {
                            // Sign In Button with Loading State
                            Button(action: signInUser) {
                                ZStack {
                                    Text("Sign In")
                                        .foregroundColor(.white)
                                        .opacity(isLoading ? 0 : 1)
                                    
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("MainColor"))
                                .cornerRadius(25)
                            }
                            .disabled(isLoading || !isEmailValid || password.isEmpty)
                            .opacity((isLoading || !isEmailValid || password.isEmpty) ? 0.6 : 1)
                            
                            // Face ID Button
                            if biometricManager.isFaceIDAvailable && useFaceID {
                                Button(action: {
                                    handleFaceIDLogin()
                                }) {
                                    Image(systemName: "faceid")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(.black)
                                        .padding(15)
                                        .background(Color(UIColor.systemGray6))
                                        .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                    else {
                        // Sign In Button with Loading State
                        Button(action: signInUser) {
                            ZStack {
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .opacity(isLoading ? 0 : 1)
                                
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("MainColor"))
                            .cornerRadius(25)
                        }
                        .disabled(isLoading || !isEmailValid || password.isEmpty)
                        .opacity((isLoading || !isEmailValid || password.isEmpty) ? 0.6 : 1)
                        .padding(.horizontal, 30)
                    }
                    
                    //Spacer()
                    
                    HStack {
                        Text("Don't have an account?")
                        NavigationLink(destination: 
                                        SignUpView().environment(\.managedObjectContext, viewContext)
                        ) {
                            Text("Sign Up")
                                .foregroundColor(Color("SubColor"))
                                .bold()
                        }
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $isSignedIn) {
                MainTabView()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
            }
            .disabled(isLoading)
        }
    }
    
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
    
    // Add Face ID login handler
    private func handleFaceIDLogin() {
        isLoading = true
        
        biometricManager.authenticateWithFaceID { success in
            DispatchQueue.main.async { [self] in
                if success {
                    // Retrieve last logged in user credentials
                    if let credentials = KeychainHelper.shared.getLastLoggedInUser() {
                        self.email = credentials.email
                        self.password = credentials.password
                        self.signInUser()
                    } else {
                        self.isLoading = false
                        self.showAlert(title: "Face ID Login",
                                       message: "Please sign in with email and password first to enable Face ID login.")
                    }
                } else {
                    self.isLoading = false
                    self.showAlert(title: "Authentication Failed",
                                   message: self.biometricManager.errorMessage)
                }
            }
        }
    }
    
    private func signInUser() {
        //        guard isEmailValid else {
        //            showAlert(title: "Error", message: "Please enter a valid email address")
        //            return
        //        }
        
        guard !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password")
            return
        }
        
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        showAlert(title: "Error", message: "Invalid password. Please try again.")
                    case AuthErrorCode.invalidEmail.rawValue:
                        showAlert(title: "Error", message: "Invalid email address.")
                    case AuthErrorCode.userNotFound.rawValue:
                        showAlert(title: "Error", message: "No account found with this email.")
                    default:
                        showAlert(title: "Error", message: error.localizedDescription)
                    }
                } else if let user = result?.user {
                    userName = user.displayName ?? user.email ?? "User"
                    KeychainHelper.shared.save(user.uid, forKey: "uid")
                    
                    // Initialize Core Data context for the user
                    PersistenceController.shared.setupInitialContext(for: user.uid)
                    
                    // Save credentials if Face ID is enabled
                    if self.useFaceID {
                        KeychainHelper.shared.saveLastLoggedInUser(email: self.email, password: self.password)
                    }
                    
                    isSignedIn = true
                }
            }
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert(title: "Error", message: "Google Sign In configuration error")
            isLoading = false
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            showAlert(title: "Error", message: "Cannot find root view controller")
            isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                showAlert(title: "Error", message: error.localizedDescription)
                isLoading = false
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                showAlert(title: "Error", message: "Cannot get user data from Google.")
                isLoading = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        showAlert(title: "Error", message: error.localizedDescription)
                    } else if let user = authResult?.user {
                        KeychainHelper.shared.save(user.uid, forKey: "uid")
                        
                        // Initialize Core Data context for the user
                        PersistenceController.shared.setupInitialContext(for: user.uid)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isSignedIn = true
                        }
                    }
                }
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
