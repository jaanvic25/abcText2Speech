//
//  abcTextViewModel.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/27/23.
//

import SwiftUI
import AVFoundation

class abcTextViewModel:ObservableObject{
   
    static let letters = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","spc", "⇧","⌫", ".","📣", "🗑", ",", "!", "?","'","-", ":", "/"]
    static let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    
    static func createABCText(chars: Int)-> abcTextModel {
        abcTextModel(numberOfChars: chars, createKeyContent: {keyIndex in
            letters[keyIndex]})
    }
    
    @Published private var model: abcTextModel = createABCText(chars: 40)
  //  @Published private var modelNums: abcTextModel = createABCText(chars: 10) //make this show up and then toggle visibiltiy
    
    
    private var uppercase = false;
    private var inputString = ""
    let synthesizer = AVSpeechSynthesizer()
    
    func getInputString() -> String{
        return model.getInputString()
    }
    
    var keys: Array<abcTextModel.Key>{
        return model.keys
    }

    func processKey(label:abcTextModel.Key){
        var value = ""
        if(label.content == "⇧"){
            uppercase = true
        } else if (label.content == "⌫") {
            model.deleteOne()
        } else if (label.content == "spc") {
            model.appendOne(value:" ")
        } else if(label.content == "📣"){
            let utterance = AVSpeechUtterance(string: model.getInputString())
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        } else if(label.content == "🗑"){
            model.clearAll()
        }
        else {
            if (uppercase){
                value = label.content.uppercased()
                uppercase = false
            } else {
                value = label.content.lowercased()
            }
            model.appendOne(value:value)
        }
        
        print("Processing key : " + label.content + " input: " + model.getInputString());
    }
}
