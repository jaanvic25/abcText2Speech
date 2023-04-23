//
//  abcTextModel.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/27/23.
//

import Foundation
import UIKit

struct abcTextModel {
    private(set) var keys: Array<Key>
    
    private var inputString = ""
    
    func getInputString() -> String{
        return inputString
    }
    
    init(numberOfChars: Int, createKeyContent: (Int) -> String) {
        keys = Array<Key>()
        for keyIndex in 0..<numberOfChars{
            let content = createKeyContent(keyIndex)
            keys.append(Key(content: content, id: keyIndex))
        }
    }
    
    struct Key: Identifiable {
        var isTyped: Bool = false
        var content: String
        var id: Int
    }
    
    mutating func appendOne(value:String){
        inputString.append(value)
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
