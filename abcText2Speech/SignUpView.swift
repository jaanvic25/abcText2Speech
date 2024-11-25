//
//  SignUpView.swift
//  abcText2Speech
//
//  Created by jaanvi Chirimar on 12/29/23.
//

import SwiftUI
import ActionButton
import Combine

var currUser = DataController.shared.savedEntities[0]

struct SignUpView: View {
    
    @StateObject private var model = LoginViewModel()
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                GroupBox{
                    Spacer()
                    VStack{
                        Text("SIGN UP")
                            .font(.title)
                        HStack{
                            TextField("First Name", text: $model.fname)
                                .submitLabel(.next)
                                .disableAutocorrection(true)
                                .focused($focus, equals: .name)
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                                .onSubmit{
                                    focus = .name
                                }
                            
                            TextField("Last Name", text: $model.lname)
                                .disableAutocorrection(true)
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
                            currUser = model.signup()
                            
                        }, backgroundColor: .primary , foregroundColor: Color(UIColor.systemBackground)
                        )
                        NavigationLink (destination: LoginView()){
                            Text("Already have a profile? Click here to Log in")
                        }
                    }
                    Spacer()
                    
                } label: {
                    Label("Welcome!", systemImage: "hand.wave")
                }
                .padding()
                .textFieldStyle(.plain)
                
                NavigationLink (destination: ContentView().navigationBarBackButtonHidden(true) , isActive: $model.isLoggedIn){
                    
                    EmptyView()
                }
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
                            currUser = model.signup()   
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
                
                
                
                NavigationLink (destination: ContentView() , isActive: $model.isLoggedIn){
                    EmptyView()
                }
                .navigationBarBackButtonHidden(true)
            }
            .navigationBarBackButtonHidden(true)
            .navigationViewStyle(.stack)
        }
    }
}

                
            
              
    
           
                
    
