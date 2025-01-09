//
//  LoginView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 10/14/23.
//

import SwiftUI
import ActionButton
import Combine


enum FocusableField: Hashable{
    case name, email, password
}


struct LoginView: View {
    
    
    @StateObject private var model = LoginViewModel()
    @FocusState private var focus: FocusableField?
    
    var body: some View {
        
        if #available(iOS 16.0, *) {
//            NavigationStack{
                GroupBox{
                    Spacer()
                    VStack{
                        Text("LOGIN")
                            .font(.title)
                        TextField("Email", text: $model.email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.next)
                            .focused($focus, equals: .email)
                            .onSubmit {
                                focus = .password
                            }
                        
                        PasswordField(title: "Password", text: $model.password)
                            .textContentType(.password)

                            .focused($focus, equals: .password)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.go)
                        
                        ActionButton(state: $model.buttonState, onTap:{
                            currUser = model.login()
                        }, backgroundColor: .primary , foregroundColor: Color(UIColor.systemBackground)
                        )
                    }
                    Spacer()
                } label: {
                    Label("Welcome Back!", systemImage: "hand.wave")
                }
                .padding()
                .textFieldStyle(.plain)
                
            NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true), isActive: $model.isLoggedIn){
                    
                    EmptyView()
                }
            
//            }
//            .navigationBarBackButtonHidden(true)
            
        } else {
            NavigationView{
                GroupBox{
                    VStack{
                        Text("LOGIN")
                        TextField("Email", text: $model.email)
                            .textContentType(.emailAddress)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .keyboardType(.emailAddress)
                            .submitLabel(.next)
                            .focused($focus, equals: .email)
                            .onSubmit {
                                focus = .password
                            }
                        
                        PasswordField(title: "Password", text: $model.password)
                            .focused($focus, equals: .password)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.go)
                            
                        
                        ActionButton(state: $model.buttonState, onTap:{
                            
                            currUser = model.login()
                        }, backgroundColor: .primary)
                    }
                } label: {
                    Label("Welcome back!", systemImage: "hand.wave")
                }
                .padding()
                .textFieldStyle(.plain)

                NavigationLink (destination: ContentView().navigationBarBackButtonHidden(true) , isActive: $model.isLoggedIn){
                    EmptyView()
                }
            }
            .navigationViewStyle(.stack)
            .navigationBarBackButtonHidden(false)
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
