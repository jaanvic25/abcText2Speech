//
//  abcTextViewModel.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/27/23.
//

import SwiftUI
import AVFoundation


class abcTextViewModel:ObservableObject{
    
    static let lettersABC = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","⌫","T","U","V","W","X","Y","Z","␣", "⇧", "🗑", ".", ",", "!", "?","'", "/","&","-","+","="]
    static let lettersQWERTY = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0","Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","⌫","Z","X","C","V","B","N","M","␣", "⇧", "🗑",".", ",", "!", "?","'", "/","&","-","+","="]
    static let numbersArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    var qwerty = false
    static func createABCText(qwerty: Bool, chars: Int)-> abcTextModel {
        if qwerty{
            return abcTextModel(numberOfChars: chars, createKeyContent: {keyIndex in
                 lettersQWERTY[keyIndex]})
        } else {
            return abcTextModel(numberOfChars: chars, createKeyContent: {keyIndex in
             lettersABC[keyIndex]})
        }
    }

    
    @Published internal var model: abcTextModel = createABCText(qwerty: false, chars: numberOfChars)
    @Published var suggestions: [String] = []
    @Published var currentInput = ""
    @Published var currentWord = ""

    private var uppercase = false;
    private var inputString = ""
    let synthesizer = AVSpeechSynthesizer()
    
    func getInputString() -> String{
        return model.getInputString()
    }
    
    var keys: Array<abcTextModel.Key>{
        return model.keys
    }

    func text2Speech(){
        let utterance = AVSpeechUtterance(string: currentInput)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func processKey(label:abcTextModel.Key){
        var value = ""
        if(label.content == "⇧"){
            uppercase = true
        } else if (label.content == "⌫") {
            if currentWord.count != 0{
                currentWord.removeLast()
            }
            model.deleteOne()
            currentInput = model.getInputString()
        } else if (label.content == "spc") {
            model.appendOne(value:" ")
            currentInput = model.getInputString()
            currentWord = ""

        } else if(label.content == "📣"){
            let utterance = AVSpeechUtterance(string: currentInput)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        } else if(label.content == "🗑"){
            currentWord = ""
            currentInput = ""
            model.clearAll()
        }
        else {
            
            if (uppercase){
                value = label.content.uppercased()
                uppercase = false
            } else {
                value = label.content.lowercased()
            }
            
            currentWord.append(value)
            model.appendOne(value:value)
            currentInput.append(value)
        }
        model.equal(value: currentInput)
        print("Processing key : " + label.content + " input: " + model.getInputString());
    }
}
