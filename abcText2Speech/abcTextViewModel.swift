//
//  abcTextViewModel.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/27/23.
//

import SwiftUI
import AVFoundation


class abcTextViewModel:ObservableObject{
    
    static let shared = abcTextViewModel()
    
    static let abc = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", ".", ",", "!", "?","'", "/"]
    static let qwerty = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M","spc", "⇧","⌫", ".", ",", "!", "?","'", "/"]
    static let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    static let phrases = ["👋", "🪪", "🙏", "❓", "💧", "p6", "p7", "p8", "p9", "p0"]
    static let phrasesOrig = [
        "👋": "Hi, how are you? ",
        "🪪": "My name is " ,
        "🙏": "Thank you. ",
        "❓": "What do you mean? ",
        "💧": "Could I have water please? ",
        "p6": currUser.p6 ?? "",
        "p7": currUser.p7 ?? "",
        "p8": currUser.p8 ?? "",
        "p9": currUser.p9 ?? "",
        "p10": currUser.p10 ?? ""]
    
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
    
    @Published var p1 = ""
    @Published var p2 = ""
    @Published var p3 = ""
    @Published var p4 = ""
    @Published var p5 = ""

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
    
    func print1(str: Double){
        print(str)
    }
    func processSep(value: String){
        if(value == "⇧"){
            uppercase = true
        } else if (value == "⌫") {
            if currentWord.count != 0{
                currentWord.removeLast()
            }
            model.deleteOne()
            currentInput = model.getInputString()
        } else if (value == "spc") {
            model.appendOne(value:" ")
            currentInput = model.getInputString()
            currentWord = ""

        } else if(value == "🗑"){
            currentWord = ""
            currentInput = ""
            model.clearAll()
        }
        model.equal(value: currentInput)
        print("Processing key : " + value + " input: " + model.getInputString());
    }
    func processKey(label:abcTextModel.Key){
        var value = ""
        if (abcTextViewModel.phrases.contains(label.content)){
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
