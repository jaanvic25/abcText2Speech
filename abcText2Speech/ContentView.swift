//
//  ContentView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import UIKit
import SwiftUI

let inputWidth = 40.0
let inputHeight = 48.0
let hSpace = 32.0
let vSpace = 24.0
var keyColor = Color.white
var textColor = Color.black



struct ContentView: View {
    
    
    @ObservedObject var viewModel = abcTextViewModel.shared
    @ObservedObject var dataController = DataController.shared
    
    let columnArray = makeColumnArray(horizontalSpacing: hSpace, keyWidth: inputWidth)
    let textChecker = UITextChecker()
    let keyboardWidth = calcKeyBoardWidth(horizontalSpacing: hSpace, keyWidth: inputWidth)
    
    let currentUser = currUser

    
    @State var selectedSuggestion: String?
    @State var showSettings: Bool = false
    
    let horizontalPadding = makePaddingHorizontal(horizontalSpacing:hSpace, keyWidth:inputWidth)
    var backgroundColor = Color(red:220/255.0,green:220/255.0, blue:220/255.0)
    
    init(){
        viewModel.phrasesDict["p2"] = "My name is " + (currentUser.firstname ?? "")
        viewModel.phrasesDict["p6"] = currentUser.p6 ?? ""
        viewModel.phrasesDict["p7"] = currentUser.p7 ?? ""
        viewModel.phrasesDict["p8"] = currentUser.p8 ?? ""
        viewModel.phrasesDict["p9"] = currentUser.p9 ?? ""
        viewModel.phrasesDict["p10"] = currentUser.p10 ?? ""
        viewModel.model = abcTextViewModel.createABCText(qwerty: false, nums: viewModel.nums, phrases: viewModel.phrasesDict)

    }
    
    var body: some View {
        
        VStack{
            
            Spacer(minLength: 100)
            Button(action: {
                showSettings = true
                
            }, label: {
                Label("", systemImage: "gear")
                Text(currentUser.email ?? " not found")
            })
            .sheet(isPresented: $showSettings, content: {
                Settings()
                
            })
            .foregroundColor(.black)
            //  .padding()
            .frame(width: CGFloat(UIScreen.main.bounds.width-20), height: 50, alignment: .trailing)
            ZStack {
                let shape = RoundedRectangle(cornerRadius: 4)
                shape
                    .fill()
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.85, height: 50)
                shape
                    .strokeBorder(lineWidth: 0.1)
                    .foregroundColor(.black)
                Text("Input: [" + viewModel.currentInput + "]")
                    .foregroundStyle(Color.black)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                
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
                    let startIndex = viewModel.currentInput.startIndex;
                    let endIndex = viewModel.currentInput.endIndex;
                    if completions != nil {
                        HStack {
                            ForEach(Array(completions!.prefix(3)), id: \.self) { suggestion in
                                Text(suggestion)
                                    .onTapGesture {
                                        if let index = viewModel.currentInput.index(endIndex, offsetBy: -viewModel.currentWord.count, limitedBy: startIndex) {
                                            viewModel.currentInput = String(viewModel.currentInput[..<index]) + suggestion + ""
                                            viewModel.currentWord = ""
                                        }
                                    }
                            }
                        }
                    }
                    
                    ForEach(Array(guesses.prefix(3)), id: \.self) { suggestion in
                        Text(suggestion)
                            .onTapGesture {
                                if let index = viewModel.currentInput.index(endIndex, offsetBy: -viewModel.currentWord.count, limitedBy: startIndex) {
                                    viewModel.currentInput = String(viewModel.currentInput[..<index]) + suggestion + " "
                                    viewModel.currentWord = ""
                                    
                                }
                            }
                    }
                    
                }
            } else {
                Text(" ")
            }
            
            ScrollView{
                HStack{
                    VStack{
                        
                        Button(action: {
                            viewModel.nums.toggle()
                            if(viewModel.nums){
                                viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: true, phrases: viewModel.phrasesDict)
                            } else{
                                viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: false, phrases: viewModel.phrasesDict)
                            }
                        }, label: {
                            if viewModel.nums {
                                Label("", systemImage: "minus.circle")
                            } else{
                                Label("", systemImage: "plus.circle")
                            }
                        })
                        .frame( height: UIScreen.main.bounds.height-80, alignment: .bottomLeading)
                    }
                    LazyVGrid(columns:columnArray, spacing:vSpace){
                        ForEach(viewModel.keys){ key in
                            keyView(key: key,
                                    keyWidth:inputWidth,
                                    keyHeight:inputHeight)
                            .onTapGesture{
                                viewModel.processKey(label:key)
                            }
                        }
                        .padding(.horizontal, horizontalPadding/2)
                    }
                    .frame(width:UIScreen.main.bounds.width * 0.5 ,height: UIScreen.main.bounds.height * 0.68, alignment: .top)
                    
                }
                if viewModel.nums{
                    Spacer(minLength: UIScreen.main.bounds.height/1.2)
                } else {
                    Spacer(minLength: UIScreen.main.bounds.height/1.8)
                }
            }
            .frame(width:UIScreen.main.bounds.width ,height: UIScreen.main.bounds.height * 0.68, alignment: .center)
            .padding()
        }
        .background(backgroundColor);
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
                .foregroundColor(keyColor)
            shape
                .strokeBorder(lineWidth: 2)
                .foregroundColor(.black)
            Text(key.content)
                .font(.system(size: 22))
                .foregroundColor(textColor)
        }
        .frame(width:keyWidth, height:keyHeight)
    }
}

struct Settings:View  {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = abcTextViewModel.shared
    
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(UIColor.lightGray)
                .opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            Text("Welcome " + (currUser.firstname ?? ""))
            VStack(alignment: .trailing){
                Button(action:{
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.title)
                        .padding(40)
                })
                VStack{
                        Button(action: {
                            viewModel.qwerty.toggle()
                            if(viewModel.qwerty){
                                viewModel.model = abcTextViewModel.createABCText(qwerty: true, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                            } else{
                                viewModel.model = abcTextViewModel.createABCText(qwerty: false, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                            }
                            
                        }){
                            if (viewModel.qwerty){
                                Text("ABC");
                            } else {
                                Text("QWERTY");
                            }
                        }
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("Change Key color")
                        })
                        Text("Customize phrases")
                    HStack{
                        
                        TextField("Custom Phrase 1", text: $viewModel.p1)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.next)
                        Button {
                            currUser.p6 = viewModel.p1
                            viewModel.phrasesDict["p6"] = currUser.p6
                            viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                        } label: {
                            Text("SAVE")
                        }
                    }
                    HStack{
                        TextField("Custom Phrase 2", text: $viewModel.p2)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.next)
                        Button {
                            currUser.p7 = viewModel.p2
                            viewModel.phrasesDict["p7"] = currUser.p7
                            viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                        } label: {
                            Text("SAVE")
                        }
                    }
                    HStack{
                        
                        TextField("Custom Phrase 3", text: $viewModel.p3)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.next)
                        Button {
                            currUser.p8 = viewModel.p3
                            viewModel.phrasesDict["p8"] = currUser.p8
                            viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                        } label: {
                            Text("SAVE")
                        }
                    }
                    HStack{
                        
                        TextField("Custom Phrase 4", text: $viewModel.p4)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.next)
                        Button {
                            currUser.p6 = viewModel.p1
                            viewModel.phrasesDict["p9"] = currUser.p9
                            viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                        } label: {
                            Text("SAVE")
                        }
                    }
                    HStack{
                        
                        TextField("Custom Phrase 5", text: $viewModel.p5)
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 10.0).strokeBorder(Color.gray, style: StrokeStyle(lineWidth: 1.0)))
                            .submitLabel(.next)
                        Button {
                            currUser.p10 = viewModel.p5
                            viewModel.phrasesDict["p10"] = currUser.p10
                            viewModel.model = abcTextViewModel.createABCText(qwerty: viewModel.qwerty, nums: viewModel.nums, phrases: viewModel.phrasesDict)
                        } label: {
                            Text("SAVE")
                        }
                    }
                }
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12")
            .preferredColorScheme(.light)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}

