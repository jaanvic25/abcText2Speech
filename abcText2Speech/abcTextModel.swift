//
//  abcTextModel.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/27/23.
//

import Foundation
import UIKit

extension String: Error {}

struct abcTextModel {
    private(set) var keys: Array<Key>
    private(set) var numKeys: Array<Key>
    private(set) var punctuationKeys: Array<Key>
    private(set) var phraseKeys: Array<Key>
    private(set) var controlKeys: Array<Key>
    private(set) var speakerKey = "📣"
    private(set) var inputLabelKey = " INPUT: "
    private(set) var gearKey = "gear"
    
    private var inputString = ""
    
    
    func getInputString() -> String{
        return inputString
    }
    
    init(keyBoards:[String:[String]], keyBoardNames:[String], qwertyFlag:Bool) {
        keys = Array<Key>()
        numKeys = Array<Key>()
        punctuationKeys = Array<Key>()
        phraseKeys = Array<Key>()
        controlKeys = Array<Key>()
        
        /*
        for keyBoardName in keyBoardNames {
            if keyBoards[keyBoardName] == nil {
                throw ("Missing Key Board: " + keyBoardName)
            }
        }*/
        
        let letterArraryName = qwertyFlag ? "qwerty":"abc"
        
        func localF(arrayToUpdate:inout Array<Key>, keyBoardName:String){
            var index = 0
            for key in keyBoards[keyBoardName]! {
                arrayToUpdate.append(Key(content: key, id: index))
                index += 1
            }
        }
        
        localF(arrayToUpdate: &keys, keyBoardName: letterArraryName)
        localF(arrayToUpdate: &numKeys, keyBoardName: "numbers")
        localF(arrayToUpdate: &punctuationKeys, keyBoardName: "punctuations")
        localF(arrayToUpdate: &phraseKeys, keyBoardName: "phrases")
        localF(arrayToUpdate: &controlKeys, keyBoardName: "controls")
        
        print(keys.map {print($0)})
    }
    
    struct Key: Identifiable {
        var isTyped: Bool = false
        var content: String
        var id: Int
    }
    
    mutating func appendOne(value:String){
        inputString.append(value)
    }
    mutating func equal(value:String){
        inputString = value
    }

    mutating func deleteOne(){
        if (inputString.count > 0){
            inputString = String(inputString.dropLast())
        }
    }
    
    mutating func clearAll(){
        inputString = ""
    }
    
    mutating func collapse(newKeys: Array<String>){
        var keyID = keys.count
        for newKey in newKeys{
            keys.append(Key(content: newKey, id: keyID))
            keyID = keyID + 1
        }
        
    }
}
