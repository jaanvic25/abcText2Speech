//
//  ContentView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import UIKit
import SwiftUI

let numberOfChars = 50
let inputWidth = 48.0
let inputHeight = 56.0
let hSpace = 32.0
let vSpace = 32.0
let fontSize = 24.0

struct ContentView: View {
    @ObservedObject var viewModel: abcTextViewModel
    let columnArray = makeColumnArray(horizontalSpacing: hSpace, keyWidth: inputWidth)
    let textChecker = UITextChecker()
    let keyboardWidth = calcKeyBoardWidth(horizontalSpacing: hSpace, keyWidth: inputWidth)
    

    @State var selectedSuggestion: String?
    
    let horizontalPadding = makePaddingHorizontal(horizontalSpacing:hSpace, keyWidth:inputWidth)
        
    var body: some View {
            VStack{
                Button(action: {
                    viewModel.qwerty.toggle()
                    if viewModel.qwerty{
                        viewModel.model = abcTextViewModel.createABCText(qwerty: true, chars: numberOfChars)
                    } else {
                        viewModel.model = abcTextViewModel.createABCText(qwerty: false, chars: numberOfChars)
                    }
                    
                }){
                    if viewModel.qwerty{
                        Text("ABC");
                    } else {
                        Text("QWERTY");
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(width: CGFloat(UIScreen.main.bounds.width), height: inputHeight,
                        alignment: .trailing)
                HStack{
                    Text("  INPUT: " + viewModel.currentInput)
                    .font(.system(size: fontSize))
                    .foregroundColor(.black)
                    .frame(width: keyboardWidth-hSpace, height: inputHeight, alignment: .leading)
                        .background(.white)
                    Button(action: {
                        viewModel.text2Speech()
                    }){
                        Text("📣")
                            .font(.system(size: 40))
                            .frame(width: inputHeight,height: inputHeight, alignment: .center)
                                .background(.white)
                    }
                }
                let completions = textChecker.completions(
                    forPartialWordRange: NSRange(0..<viewModel.currentWord.utf16.count),
                                    in: viewModel.currentWord,
                                    language: "en_US"
                                  )
                let misspelledRange =
                textChecker.rangeOfMisspelledWord(in: viewModel.currentWord,
                                                      range: NSRange(0..<viewModel.currentWord.utf16.count),
                                                      startingAt: 0,
                                                      wrap: false,
                                                      language: "en_US")

                if misspelledRange.location != NSNotFound,
                    let guesses = textChecker.guesses(forWordRange: misspelledRange,
                                                         in: viewModel.currentWord,
                                                         language: "en_US")?.prefix(3)
                {
                    HStack{
                        if completions != nil {
                            HStack{
                                ForEach(Array(completions!.prefix(3)), id: \.self) { suggestion in
                                    Text(suggestion)
                                        .onTapGesture {
                                            if let index = viewModel.currentInput.index(viewModel.currentInput.endIndex, offsetBy: -viewModel.currentWord.count, limitedBy: viewModel.currentInput.startIndex) {
                                                viewModel.currentInput = String(viewModel.currentInput[..<index]) + suggestion + " "
                                                        viewModel.currentWord = ""
                                                                
                                            }
                                        }
                                }
                            }
                        }
                        ForEach(Array(guesses.prefix(3)), id: \.self) { suggestion in
                            Text(suggestion)
                                .onTapGesture {
                                    if let index = viewModel.currentInput.index(viewModel.currentInput.endIndex, offsetBy: -viewModel.currentWord.count, limitedBy: viewModel.currentInput.startIndex) {
                                        viewModel.currentInput = String(viewModel.currentInput[..<index]) + suggestion + " "
                                                viewModel.currentWord = ""
                                                        
                                    }
                                }
                        }
                    }
                    .font(.system(size: fontSize))
                    .foregroundColor(.white)
                } else {
                    Text(" ")
                        .font(.system(size: fontSize))
                        .foregroundColor(.white)
                }
                ScrollView{
                    LazyVGrid(columns:columnArray, spacing:vSpace){
                        ForEach(viewModel.keys){ key in
                            keyView(key: key,
                                    keyWidth:inputWidth,
                                    keyHeight:inputHeight)
                            .onTapGesture{
                                viewModel.processKey(label:key)
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding/2)
                }
                .frame(height: UIScreen.main.bounds.height * 0.68)
                .padding()
            }
            .background(Color(red:32.0/255.0,green:42.0/255.0,blue:68.0/255.0,opacity:1))
    }
}

func calcNumberOfColumns()->CGFloat{
    return CGFloat(10);
}

func makeColumnArray(horizontalSpacing:CGFloat, keyWidth:CGFloat)->[GridItem]{
    let numberOfColumns = (Int)(calcNumberOfColumns());
    var columnArray:[GridItem] = []
    
    for _ in 0..<numberOfColumns{
        columnArray.append(GridItem())
    }
    
    return columnArray
}

func calcKeyBoardWidth(horizontalSpacing: CGFloat, keyWidth:CGFloat)->CGFloat{
    let numberOfColumns = calcNumberOfColumns();
    let keyboardWidth = numberOfColumns*keyWidth + (numberOfColumns - 1)*horizontalSpacing;
    
    return keyboardWidth;
}

func makePaddingHorizontal(horizontalSpacing: CGFloat, keyWidth:CGFloat)->CGFloat{
    let screenWidth = CGFloat(UIScreen.main.bounds.width);
    let keyboardWidth = calcKeyBoardWidth(horizontalSpacing: horizontalSpacing, keyWidth: keyWidth);
    let padding = screenWidth - keyboardWidth;
    
    return padding;
}

struct keyView: View {
    let key: abcTextModel.Key
    
    var keyWidth:CGFloat
    var keyHeight:CGFloat
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 8)
            shape
                .fill()
                .foregroundColor(Color(red:255.0/255.0,green:255.0/255.0,blue:255.0/255.0,opacity:1.0))
            shape
                .strokeBorder(lineWidth: 2)
                .foregroundColor(.black)
            Text(key.content)
                .font(.system(size: fontSize))
                .foregroundColor(.black)
        }
        .frame(width:keyWidth, height:keyHeight)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let keyboard = abcTextViewModel()
        ContentView(viewModel: keyboard)
            .previewDevice("iPhone 12")
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

