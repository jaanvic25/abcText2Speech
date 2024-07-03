//
//  abcText2SpeechApp.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import SwiftUI

@main
struct abcText2SpeechApp: App {
    @ObservedObject private var dataController = DataController()
    var body: some Scene {
        WindowGroup{
            SignUpView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                
        }
        
    }
}
