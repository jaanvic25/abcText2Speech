//
//  ContentView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import UIKit
import SwiftUI

let inputWidth = 64.0
let inputHeight = 76.0
let hSpace = 32.0
let vSpace = 24.0

struct ContentView: View {
    @ObservedObject var viewModel: abcTextViewModel
    let columnArray = makeColumnArray(horizontalSpacing: hSpace, keyWidth: inputWidth)
    let textChecker = UITextChecker()

    @State var selectedSuggestion: String?
    
    let horizontalPadding = makePaddingHorizontal(horizontalSpacing:hSpace, keyWidth:inputWidth)
        
    var body: some View {
            VStack{
                Button(action: {
                    viewModel.qwerty.toggle()
                    if viewModel.qwerty{
                        viewModel.model = abcTextViewModel.createABCText(qwerty: true, chars: 48)
                    } else {
                        viewModel.model = abcTextViewModel.createABCText(qwerty: false, chars: 48)
                    }
                    
                }){
                    if viewModel.qwerty{
                        Text("ABC");
                    } else {
                        Text("QWERTY");
                    }
                }
                .foregroundColor(.black)
                .padding()
                .frame(width: CGFloat(UIScreen.main.bounds.width-20), height: 50, alignment: .trailing)
                Text("Input: [" + viewModel.currentInput + "]")
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
                    var numSuggest = 0
                    HStack{
                        if completions == nil {
                           // numSuggest = 3
                            //error with numSuggest 
                            
                        } else {
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
                } else {
                    Text("Not found")
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
            .background(Color(red:220.0/255.0,green:220.0/255.0,blue:220.0/255.0))
    }
}

func calcNumberOfColumns(horizontalSpacing:CGFloat, keyWidth:CGFloat)->CGFloat{
    let screenWidth = UIScreen.main.bounds.width;
    var numberOfColumns = (Int)(floor(screenWidth - horizontalSpacing)/(keyWidth + horizontalSpacing));
    
    if (numberOfColumns < 3){
        numberOfColumns = 3;
    }
    
    if (numberOfColumns > 8){
        numberOfColumns = 8;
    }
    
    return CGFloat(numberOfColumns);
}

func makeColumnArray(horizontalSpacing:CGFloat, keyWidth:CGFloat)->[GridItem]{
    let numberOfColumns = (Int)(calcNumberOfColumns(horizontalSpacing:horizontalSpacing, keyWidth:keyWidth));
    var columnArray:[GridItem] = []
    
    for _ in 0..<numberOfColumns{
        columnArray.append(GridItem())
    }
    
    return columnArray
}

func makePaddingHorizontal(horizontalSpacing: CGFloat, keyWidth:CGFloat)->CGFloat{
    let numberOfColumns = calcNumberOfColumns(horizontalSpacing:horizontalSpacing, keyWidth:keyWidth);
    let screenWidth = CGFloat(UIScreen.main.bounds.width);
    let padding = screenWidth - numberOfColumns*keyWidth - (numberOfColumns - 1)*horizontalSpacing;
    
    return padding;
}

struct keyView: View {
    let key: abcTextModel.Key
    
//    var label:String
    var keyWidth:CGFloat
    var keyHeight:CGFloat
    
    var body: some View {
        ZStack {
            let shape = RoundedRectangle(cornerRadius: 8)
            shape
                .fill()
                .foregroundColor(.white)
            shape
                .strokeBorder(lineWidth: 2)
                .foregroundColor(.black)
            Text(key.content)
                .font(.largeTitle)
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

