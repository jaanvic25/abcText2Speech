//
//  SignUpView.swift
//  abcText2Speech
//
//  Created by jaanvi Chirimar on 12/29/23.
//

import SwiftUI
import ActionButton
import Combine

struct SignUpView: View {
    
    @StateObject private var model = LoginViewModel()
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        var user = UserEntity()
        var signup = (user, 10)
        if #available(iOS 16.0, *) {
            NavigationStack {
                GroupBox{
                    VStack{
                        Text("SIGN UP")
                            .font(.title)
                        HStack{
                            TextField("First Name", text: $model.fname)
                                .submitLabel(.next)
                                .focused($focus, equals: .name)
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                                .onSubmit{
                                    focus = .name
                                }
                            
                            TextField("Last Name", text: $model.lname)
                                .submitLabel(.next)
                                .focused($focus, equals: .name)
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                                .onSubmit {
                                    focus = .email
                                }
                        }
                        TextField("Email", text: $model.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                        
                            .focused($focus, equals: .email)
                            .onSubmit {
                                focus = .password
                            }
                        
                        PasswordField(title: "Password", text: $model.password)
                            .focused($focus, equals: .password)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                        
                            .submitLabel(.go)
                        
                        ActionButton(state: $model.buttonState, onTap:{
                            signup = model.signup()
                            user = signup.0
                            
                        }, backgroundColor: .primary , foregroundColor: Color(UIColor.systemBackground)
                        )
                        NavigationLink (destination: LoginView()){
                            Text("Already have a profile? Click here to Log in")
                        }
                    }
                } label: {
                    Label("Welcome!", systemImage: "hand.wave")
                }
                .padding()
                .textFieldStyle(.plain)
                let keyboard = abcTextViewModel()
                
                NavigationLink (destination: ContentView(viewModel: keyboard, currentUser: user) , isActive: $model.isLoggedIn){
                    
                    EmptyView()
                }
                .navigationBarBackButtonHidden(true)
            }
        } else {
            NavigationView{
                GroupBox{
                    VStack{
                        Text("SIGN UP")
                            .font(.title)
                        TextField("Email", text: $model.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .focused($focus, equals: .email)
                            .onSubmit {
                                focus = .password
                            }
                        
                        PasswordField(title: "Password", text: $model.password)
                            .focused($focus, equals: .password)
                            .submitLabel(.go)
                        
                        ActionButton(state: $model.buttonState, onTap:{
                            signup = model.signup()
                            if signup.1 == 1 {
                                user = signup.0
                            }
                            user = signup.0
                        }, backgroundColor: .primary)
                        NavigationLink (destination: LoginView()){
                            Text("Already have a profile? Click here to Log in")
                        }
                    }
                } label: {
                    Label("Welcome back!", systemImage: "hand.wave")
                }
                .padding()
                .textFieldStyle(.plain)
                
                
                //ContentView(viewModel: keyboard)
                
                let keyboard = abcTextViewModel()
                NavigationLink (destination: ContentView(viewModel: keyboard, currentUser: user) , isActive: $model.isLoggedIn){
                    EmptyView()
                }
                .navigationBarBackButtonHidden(true)
            }
            .navigationBarBackButtonHidden(true)
            .navigationViewStyle(.stack)
        }
    }
}

                
            
              
    
           
                
    
