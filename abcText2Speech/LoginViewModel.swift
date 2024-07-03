//
//  LoginViewModel.swift
//  abcText2Speech
//
//  Created by jaanvi Chirimar on 1/6/24.
//

import Foundation
import SwiftUI
import Combine
import ActionButton



class LoginViewModel: ObservableObject{
    
    @Published var buttonState: ActionButtonState = .disabled(title: "Fill out all fields to log in", systemImage: "exclamationmark.circle")
    
    @Published var fname: String = ""
    @Published var lname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoggedIn: Bool = false
    @StateObject var dataController = DataController()
  
    private var cancellable: Set<AnyCancellable> = []
    
    
    func isValidEmail() -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
        
    }
    
    func isValidPassword() -> Bool {
        if password.count > 6 {
            return true
        } else {
            return false
        }
    }
    
    func isValidName() -> Bool {
        if fname.count > 1 {
            if lname.count > 1{
                return true
            }
        }
            return false

    }
    
    private var isEmailValidPub: AnyPublisher<Bool, Never>{
        
        $email
            .map{value in
                !value.isEmpty
            }
            .eraseToAnyPublisher()
    }
    

    private var isPasswordValidPub: AnyPublisher<Bool, Never>{
        $password
            .map{value in
                !value.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    init(){
        isEmailValidPub
            .combineLatest(isPasswordValidPub)
            .map {
                value1, value2 in
                value1 && value2
            }

            .map { fieldsValid -> ActionButtonState in
                if fieldsValid && self.isValidEmail() && self.isValidPassword() {
                    return .enabled(title: "Login" , systemImage: "checkmark.circle")
                } else if fieldsValid && self.isValidEmail() {
                    return .disabled(title: "Password must be 8 characters or longer", systemImage: "exclamationmark.circle")
                } else if fieldsValid {
                    return .disabled(title: "Invalid email", systemImage: "exclamationmark.circle")
                }  else {
                    return .disabled(title: "Fill out all fields to log in", systemImage: "exclamationmark.circle")
                }
            }
            .assign(to: \.buttonState, on: self)
            .store(in: &cancellable)
    }
    
    func signup()-> (UserEntity, Int){
        @StateObject var dataController = DataController()
        
        buttonState = .loading(title: "Loading", systemImage: "person")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
            if self.isValidEmail() && self.isValidPassword() && self.isValidName(){
                self.isLoggedIn = true
                dataController.addUser(firstname: self.fname, lastname: self.lname, email: self.email, password: self.password)
                
                print("signed in")
                print(self.isLoggedIn)
                self.buttonState = .enabled(title: "Login", systemImage: "checkmark.circle")
            } else{
                self.buttonState = .disabled(title: "Fill out all fields to log in", systemImage: "exclamationmark.circle")
            }
        }
        print(self.isLoggedIn)
        print(dataController.savedEntities[(dataController.savedEntities.count)-1].email!)
        
        return (dataController.savedEntities[(dataController.savedEntities.count)-1], 1)

    }
    
    
    func login() -> (UserEntity, Int){
        @StateObject var dataController = DataController()
        var userVerified: Bool = false
        var correctPassword: Bool = false
        var ct = 0
        for entity in dataController.savedEntities {
            if entity.email == self.email {
                userVerified = true
                if entity.id == self.password{
                    correctPassword = true
                    break;
                }
            } else{
                ct = ct + 1
            }
            print(entity.email ?? "email?")
            print(entity.id ?? "pass?")
        }
        
        
        buttonState = .loading(title: "Loading", systemImage: "person")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
            if userVerified && correctPassword{
                self.isLoggedIn = true
                print("logged in")
                self.buttonState = .enabled(title: "Login", systemImage: "checkmark.circle")
            }
            else if userVerified {
                self.buttonState = .disabled(title: "Incorrect password", systemImage: "exclamationmark.circle")
            }
            else {
                self.buttonState = .disabled(title: "Email is new to the system, sign up instead", systemImage: "exclamationmark.circle")
            }
        }
        print("here")
       
//        if userVerified && correctPassword{
            return (dataController.savedEntities[ct], 1)
//        } else {
//            return (dataController.savedEntities[0], 0)
//        }
    }
    
}

struct PasswordField: View {
    let title: String
    @Binding var text: String
    
    @State private var passwordHidden: Bool = true
    var body: some View{
        ZStack(alignment: .trailing){
            if passwordHidden{
                SecureField(title, text: $text)
            } else{
                TextField(title, text: $text)
                    .disableAutocorrection(true)
            }
            Button{
                passwordHidden.toggle()
            } label: {
                if passwordHidden{
                    Image(systemName: "eye.slash")
                } else{
                    Image(systemName: "eye")
                }
            } .foregroundColor(.primary)
        }
        .frame(height: 18)
    }
}
