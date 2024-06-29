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
        var user = UserEntity()
        var login = (user, 10)
        if #available(iOS 16.0, *) {
            NavigationStack{
                GroupBox{
                    VStack{
                        Text("LOGIN")
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
                            login = model.login()
                            user = login.0
                        }, backgroundColor: .primary , foregroundColor: Color(UIColor.systemBackground)
                        )
                    }
                } label: {
                    Label("Welcome back!", systemImage: "hand.wave")
                }
                .padding()
                .textFieldStyle(.plain)
                
                
                let keyboard = abcTextViewModel()
                Text("USER: " + user.email!)
                let tempContentView = ContentView(viewModel: keyboard, currentUser: user)
                NavigationLink(destination: tempContentView,
                               isActive: $model.isLoggedIn){EmptyView()}
            
            }
            .navigationBarBackButtonHidden(false)
            
        } else {
            NavigationView{
                GroupBox{
                    VStack{
                        Text("LOGIN")
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
                            
                            user = model.login().0
                        }, backgroundColor: .primary)
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
