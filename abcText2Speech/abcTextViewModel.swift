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
    
    static let abc = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", ]
    static let qwerty = ["Q","W","E","R","T","Y","U","I","O","P","A","S","D","F","G","H","J","K","L","Z","X","C","V","B","N","M"]
    static let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    static let punctuations = [".", ",", "!", "?","'", "/"]
    static let phrases = ["👋", "🪪", "🙏", "❓", "💧"]
    static let controls = ["Spc","⇧", "⌫", "🗑"]
    static let keyBoardNames = ["abc","qwerty", "numbers", "punctuations", "phrases", "controls"]
    static let keyBoards = [
        abcTextViewModel.keyBoardNames[0]:abcTextViewModel.abc,
        abcTextViewModel.keyBoardNames[1]:abcTextViewModel.qwerty,
        abcTextViewModel.keyBoardNames[2]:abcTextViewModel.numbers,
        abcTextViewModel.keyBoardNames[3]:abcTextViewModel.punctuations,
        abcTextViewModel.keyBoardNames[4]:abcTextViewModel.phrases,
        abcTextViewModel.keyBoardNames[5]:abcTextViewModel.controls,
    ]
    static let phrasesOrig = [
        "👋": "Hi, how are you? ",
        "🪪": "My name is " ,
        "🙏": "Thank you. ",
        "❓": "What do you mean? ",
        "💧": "Could I have water please? "]
    
    static let customPhrases =  [
        currUser.p6 ?? "", currUser.p7 ?? "", currUser.p8 ?? "", currUser.p9 ?? "",  currUser.p10 ?? ""]
    
    var qwertyFlag = false
    var phrasesDict = phrasesOrig
   
    static func createABCText(qwertyFlag: Bool, phrasesDictLocal: Dictionary<String, String>)-> abcTextModel {
        return abcTextModel(keyBoards:keyBoards, keyBoardNames:keyBoardNames, qwertyFlag:qwertyFlag)
    }

    
    @Published internal var modelABCTextModel: abcTextModel = createABCText(qwertyFlag: false, phrasesDictLocal: phrasesOrig)

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
        return modelABCTextModel.getInputString()
    }
    
    var keys: Array<abcTextModel.Key>{
        return modelABCTextModel.keys
    }
    
    var numKeys: Array<abcTextModel.Key>{
        return modelABCTextModel.numKeys
    }
    
    var punctuationKeys: Array<abcTextModel.Key>{
        return modelABCTextModel.punctuationKeys
    }
    
    var phraseKeys: Array<abcTextModel.Key>{
        return modelABCTextModel.phraseKeys
    }
    
    var custPhrases: Array<CustomPhraseIdentifiable>{
        return [CustomPhraseIdentifiable(title: currUser.p6 ?? ""),
                CustomPhraseIdentifiable(title: currUser.p7 ?? ""),
                CustomPhraseIdentifiable(title: currUser.p8 ?? ""),
                CustomPhraseIdentifiable(title: currUser.p9 ?? ""),
                CustomPhraseIdentifiable(title: currUser.p10 ?? "")]
    }
    
    
    struct CustomPhraseIdentifiable : Identifiable{
       let id = UUID()
       let title: String
   }

    func text2Speech(){
        let utterance = AVSpeechUtterance(string: currentInput)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    func print1(str: Double){
        print(str)
    }
    
    func processKey(label:String){
        var value = ""
        
        if let systemPhraseValue = phrasesDict[label] {
            modelABCTextModel.appendOne(value: systemPhraseValue)
            currentWord.append(systemPhraseValue)
            currentInput.append(systemPhraseValue)
        } else if (abcTextViewModel.customPhrases.contains(label)){
            for phrase in custPhrases {
                if phrase.title == value {
                    modelABCTextModel.appendOne(value: phrase.title)
                    currentWord.append(phrase.title)
                    currentInput.append(phrase.title)
                }
            }
        } else if(label == "📣"){
            let utterance = AVSpeechUtterance(string: currentInput)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            synthesizer.speak(utterance)
        } else if(label == "🗑"){
            currentWord = ""
            currentInput = ""
            modelABCTextModel.clearAll()
        } else if(label == "⇧"){
            uppercase = true
        } else if (label == "⌫") {
            if currentWord.count != 0{
                currentWord.removeLast()
            }
            modelABCTextModel.deleteOne()
            currentInput = modelABCTextModel.getInputString()
        } else {
            if (uppercase){
                value = label.uppercased()
                uppercase = false
            } else {
                value = label.lowercased()
            }
            
            currentWord.append(value)
            modelABCTextModel.appendOne(value:value)
            currentInput.append(value)
        }
        modelABCTextModel.equal(value: currentInput)
        print("Processing key : " + label + " input: " + modelABCTextModel.getInputString());
    }
}
