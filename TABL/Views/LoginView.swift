//
//  LoginView.swift
//  TABL
//
//  Created by Ignacio Canto on 12/4/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

//TO-DO: ADD Logo
//Add theme colors

struct LoginView: View {
    enum Field {
        case email, password
    }
    
    enum UserType {
        case admin
        case regularUser
    }
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var buttonsDisabled = true
    @State private var presentSheet = false
    @State private var selectedUserType: UserType = .regularUser // Default to regular user
    @FocusState private var focusField: Field?
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Image("TABL_") //TO-DO ADD LOGO HERE
                    .resizable()
                    .scaledToFit()
                    .padding()
                
                // User type selector
                Picker("Login Type", selection: $selectedUserType) {
                    Text("User").tag(UserType.regularUser)
                    Text("Administrator").tag(UserType.admin)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .colorScheme(.dark)
                
                Group {
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .focused($focusField, equals: .email) // this field is bound to the .email case
                        .onSubmit {
                            focusField = .password
                        }
                        .onChange(of: email) {
                            enableButtons()
                        }
                    
                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .focused($focusField, equals: .password) // this field is bound to the .password case
                        .onSubmit {
                            focusField = nil // will dismiss the keyboard
                        }
                        .onChange(of: password) {
                            enableButtons()
                        }
                }
                .textFieldStyle(.roundedBorder)
                .colorScheme(.dark)
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.gray.opacity(0.5), lineWidth: 2)
                }
                .padding(.horizontal)
                
                HStack {
                    Button {
                        register()
                    } label: {
                        Text("Sign Up")
                            .foregroundColor(.black)
                    }
                    .padding(.trailing)
                    
                    Button {
                        login()
                    } label: {
                        Text("Log In")
                            .foregroundColor(.black)
                    }
                    .padding(.leading)
                }
                .disabled(buttonsDisabled)
                .buttonStyle(.glassProminent)
                .tint(buttonsDisabled ? .gray : .white)
                .font(.title2)
                .padding(.top)
                
                // Show different helper text based on selected user type
                Text(selectedUserType == .regularUser ?
                     "Regular users can browse and view club information" :
                        "Administrators can manage clubs and content")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 8)
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        }
        .onAppear {
            // Debug icon setup
            print("🔍 Debugging App Icon Setup:")
            if let bundlePath = Bundle.main.path(forResource: "AppIcon60x60", ofType: "png") {
                print("✅ Found AppIcon in bundle: \(bundlePath)")
            } else {
                print("❌ AppIcon not found in bundle")
            }
            
            // Check if we have any app icon variants
            let iconNames = ["AppIcon", "AppIcon60x60", "AppIcon120x120", "AppIcon180x180"]
            for iconName in iconNames {
                if Bundle.main.path(forResource: iconName, ofType: "png") != nil {
                    print("✅ Found: \(iconName).png")
                } else if Bundle.main.path(forResource: iconName, ofType: nil) != nil {
                    print("✅ Found: \(iconName)")
                }
            }
            
            // if logged in when app runs, navigate to the new screen & skip login screen
            if Auth.auth().currentUser != nil {
                checkUserTypeAndNavigate()
            }
        }
        .fullScreenCover(isPresented: $presentSheet) {
            // Navigate to different views based on user type
            if selectedUserType == .admin {
                ListView() // Admin view with full CRUD capabilities
            } else {
                UserListView() // Read-only view for regular users
            }
        }
    }
    
    func clearFields() {
        email = ""
        password = ""
    }
    
    func enableButtons() {
        let emailIsGood = email.count >= 6 && email.contains("@")
        let passwordIsGood = password.count >= 6
        buttonsDisabled = !(emailIsGood && passwordIsGood)
    }
    
    func checkUserTypeAndNavigate() {
        // Check if current user is admin based on your business logic
        // This could be done by checking user's email domain, Firestore user role, etc.
        guard let user = Auth.auth().currentUser else { return }
        
        // Example: Check if user email contains "admin" or is in admin domain
        if isAdminUser(email: user.email ?? "") {
            selectedUserType = .admin
        } else {
            selectedUserType = .regularUser
        }
        
        print("🪵 Login Successful!")
        presentSheet = true
    }
    
    func isAdminUser(email: String) -> Bool {
        // Implement your admin check logic here
        // Examples:
        // - Check if email contains "admin"
        // - Check if email is from specific domain like "@yourcompany.com"
        // - Query Firestore for user role
        // - Check against a predefined list of admin emails
        
        return email.contains("admin") || email.hasSuffix("@yourcompany.com")
    }
    
    func register() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { // login error occurred
                print("😡 SIGN-UP ERROR: \(error.localizedDescription)")
                alertMessage = "SIGN-UP ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("😎 Registration success!")
                
                // After successful registration, you might want to store user type in Firestore
                storeUserType()
                
                clearFields()
                presentSheet = true
            }
        }
    }
    
    func storeUserType() {
        // Store user type in Firestore for future reference
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "email": user.email ?? "",
            "userType": selectedUserType == .admin ? "admin" : "regular",
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Error storing user type: \(error)")
            } else {
                print("User type stored successfully")
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error { // login error occurred
                print("😡 LOGIN ERROR: \(error.localizedDescription)")
                alertMessage = "LOGIN ERROR: \(error.localizedDescription)"
                showingAlert = true
            } else {
                print("🪵 Login Successful!")
                
                // Check user type from Firestore and set selectedUserType accordingly
                checkStoredUserType()
                
                clearFields()
                presentSheet = true
            }
        }
    }
    
    func checkStoredUserType() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let userType = data?["userType"] as? String ?? "regular"
                
                DispatchQueue.main.async {
                    self.selectedUserType = userType == "admin" ? .admin : .regularUser
                }
            } else {
                // If no user type stored, default to regular user
                self.selectedUserType = .regularUser
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            // Handle navigation back to login
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
#Preview {
    LoginView()
}
