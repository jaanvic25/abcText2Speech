//
//  ContentView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import UIKit
import SwiftUI

let inputHeight = UIScreen.main.bounds.height / 6.84// 48.0
let inputWidth = inputHeight * 0.8333333// 40
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
            
            HStack{
                Spacer()
                    .frame(width: horizontalPadding/2, height: 20, alignment: .trailing)
                Text("   INPUT: " + viewModel.currentInput)
                    .font(.title3)
                    .foregroundColor(.black)
                
                    .frame(width: calcNumberOfColumns()*inputWidth+100, height: inputHeight, alignment: .leading)
                        .background(.white)
                
                Button(action: {viewModel.text2Speech()}){
                    Text("📣")
                        .font(.system(size:40))
                        .frame(width: inputHeight, height: inputHeight, alignment: .center)
                            .background(.white)
                }
                Spacer()
                    .frame(width: 40, height: 20, alignment: .trailing)
                Button(action: {
                    showSettings = true
                    
                }, label: {
                    Label("", systemImage: "gear")
                })
                .sheet(isPresented: $showSettings, content: {
                    if #available(iOS 16.0, *){
                        Settings()
                            .presentationDetents([.large])
                    } else {
                        Settings()
                    }
                    
                })
                .foregroundColor(.black)
     
                .frame(width: 30, height: inputHeight, alignment: .topTrailing)
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
                Text("no suggestions found")
            }
            HStack {
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
                        .padding(.horizontal, horizontalPadding/3)
                    }
                    
                    .frame(width: calcNumberOfColumns()*inputWidth+100,height: UIScreen.main.bounds.height * 0.68, alignment: .top)
                    
                    Spacer(minLength: UIScreen.main.bounds.height/1.5)
                }
                Spacer()
                    .frame(width: 10)
                VStack{
                    Button(action: {viewModel.processSep(value:"spc")}){
                        Text("spc")
                            .font(.system(size:20))
                            .foregroundStyle(.black)
                            .frame(width: inputWidth, height: inputHeight * 0.9, alignment: .center)
                            .background(.white)
                    }
                    Button(action: {viewModel.processSep(value: "⇧")}){
                        Text("⇧")
                            .font(.system(size:20))
                            .foregroundStyle(.black)
                            .frame(width: inputWidth, height: inputHeight * 0.9, alignment: .center)
                            .background(.white)
                    }
                    Button(action: {viewModel.processSep(value: "⌫")}){
                        Text("⌫")
                            .font(.system(size:20))
                            .foregroundStyle(.black)
                            .frame(width: inputWidth, height: inputHeight * 0.9, alignment: .center)
                            .background(.white)
                    }
                    
                    Button(action: {viewModel.processSep(value: "🗑")}){
                        Text("🗑")
                            .font(.system(size:20))
                            .frame(width: inputWidth, height: inputHeight * 0.9, alignment: .center)
                            .background(.white)
                    }
                    Spacer(minLength: 10)
                        .frame(width: inputWidth, height: 20, alignment: .center)
                        .foregroundStyle(.black)
                        .background(backgroundColor)
//                        .frame(width: inputWidth, height: inputHeight * 0.8, alignment: .center)
                }
                .frame(width: inputWidth+5, height: UIScreen.main.bounds.height * 0.75, alignment: .top)
            }
            .frame(width:UIScreen.main.bounds.width ,height: UIScreen.main.bounds.height * 0.75, alignment: .top)
            
            .padding()
            
        }
        .background(backgroundColor);
    }
    
}
   

func calcNumberOfColumns()->CGFloat{
    let totalWidth = UIScreen.main.bounds.width
    let availableWidth = totalWidth - (2 * 10   ) // Account for padding
   // print(calcKeyBoardWidth(horizontalSpacing: hSpace, keyWidth: inputWidth), UIScreen.main.bounds.width * 0.5)
    return floor(availableWidth / (inputWidth + hSpace+10))
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
                .opacity(0.2)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack{
                Spacer()
                    .frame(width:UIScreen.main.bounds.width, height: 20, alignment: .center)
                HStack{
                    Text("Welcome " + (currUser.firstname ?? ""))
                        .frame(width:UIScreen.main.bounds.width*0.22, height: 20, alignment: .bottomLeading)
                    Spacer()
                        .frame(width:UIScreen.main.bounds.width*0.52, height: 20, alignment: .bottomTrailing)
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(.title)
                            .padding(40)
                    })
                }
                .frame(width:UIScreen.main.bounds.width*0.8, height: 30, alignment: .leading)
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
                .frame(width:UIScreen.main.bounds.width*0.8, height: 20, alignment: .leading)
                Text("Customize phrases")
                    .frame(width:UIScreen.main.bounds.width*0.8, height: 20, alignment: .leading)
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
            .frame(width:UIScreen.main.bounds.width*0.8, height: UIScreen.main.bounds.height, alignment: .center)
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

