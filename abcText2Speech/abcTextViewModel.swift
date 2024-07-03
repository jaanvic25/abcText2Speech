//
//  abcTextViewModel.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/27/23.
//

import SwiftUI
import AVFoundation


class abcTextViewModel:ObservableObject{
    
    static let abc = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","spc", "⇧","⌫", ".","📣", "🗑", ",", "!", "?","'", ":", "/"]
    static let qwerty = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","spc", "⇧","⌫", ".","📣", "🗑", ",", "!", "?","'", ":", "/"]
    static let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    static let phrases = ["p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p0"]
    static let phrasesOrig = [
        "p1": "Hi, how are you?",
        "p2": "My name is ",
        "p3": "Thank you.",
        "p4": "I'm sorry.",
        "p5": "Could I have water please?",
        "p6": "",
        "p7": "",
        "p8": "",
        "p9": "",
        "p10": ""]
    
    static let lettersABC = abc + phrases
    static let lettersQWERTY = qwerty + phrases
    static let abcNum = abc + numbers + phrases
    static let qwertyNum = qwerty + numbers + phrases
    var qwerty = false
    var nums = true
    var phrasesDict = phrasesOrig
    static func createABCText(qwerty: Bool, nums: Bool, phrases: Dictionary<String, String>)-> abcTextModel {

        if qwerty{
            if nums{
                return abcTextModel(numberOfChars: qwertyNum.count, createKeyContent: {keyIndex in
                    qwertyNum[keyIndex]})
            } else {
                return abcTextModel(numberOfChars: lettersQWERTY.count, createKeyContent: {keyIndex in
                    lettersQWERTY[keyIndex]})
            }
        } else {
            if nums{
                return abcTextModel(numberOfChars: abcNum.count, createKeyContent: {keyIndex in
                    abcNum[keyIndex]})
            } else {
                return abcTextModel(numberOfChars: lettersABC.count, createKeyContent: {keyIndex in
                    lettersABC[keyIndex]})
            }
        }
    }

    
    @Published internal var model: abcTextModel = createABCText(qwerty: false, nums: true, phrases: phrasesOrig)

    @Published var suggestions: [String] = []
    @Published var currentInput = ""
    @Published var currentWord = ""

    private var uppercase = false;
    private var inputString = ""
    let synthesizer = AVSpeechSynthesizer()
    
    func addone(inp: Int) -> Int{
        return inp + 1
    }
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

        } else if (abcTextViewModel.phrases.contains(label.content)){
            for key in phrasesDict.keys {
                if key == label.content {
                    model.appendOne(value: phrasesDict[key]!)
                    currentWord.append(phrasesDict[key] ?? "")
                    currentInput.append(phrasesDict[key] ?? "")
                }
            }
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
