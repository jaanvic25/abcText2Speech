//
//  abcText2SpeechApp.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import SwiftUI

@main
struct abcText2SpeechApp: App {
    let keyboard = abcTextViewModel()
    var body: some Scene {
        WindowGroup{
            ContentView(viewModel: keyboard)
        }
    }
}
