//
//  ContentView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import UIKit
import SwiftUI

let hSpace = 28.0
let vSpace = 22.0
var keyColor = Color.white
var textColor = Color.black

let minKWidth = 32.0; //TEST VAR
let maxKWdith = 64.0; //TEST VAR

let minSWidth = 812; //TEST VAR
let maxSWdith = 1600; //TEST VAR
//let scrW = UIScreen.main.bounds.width;
//let screenHeight = UIScreen.main.bounds.height;

//let screenHeight = UIScreen.main.bounds.width;
//let screenWidth = UIScreen.main.bounds.height;

struct ContentView: View {
    
    
    
    @ObservedObject var viewModel = abcTextViewModel.shared
    @ObservedObject var dataController = DataController.shared
    @State var selectedSuggestion: String?
    @State var showSettings: Bool = false
    @State var screenSize: CGSize = UIScreen.main.bounds.size
   
    var kWidth: CGFloat {
        calcKWidth(scrW: screenSize.width)
    }
    var keyboardWidth: CGFloat {
        calcKeyBoardWidth(scrW: screenSize.width)
    }
    var columnArray: [GridItem] {
        makeColumnArray(scrW: screenSize.width)
    }
    
    let textChecker = UITextChecker()
    
    let currentUser = currUser
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
        let kHeight = calcKWidth(scrW: screenSize.width)*1.2// 48.0
        let horizontalPadding = 2*calcKWidth(scrW: screenSize.width)
        GeometryReader { geometry in
            var scrW = geometry.size.width
            var screenHeight = geometry.size.height
            
            // Dynamically update screenSize state to trigger layout updates on rotation
            Color.clear
                .onAppear {
                    self.screenSize = geometry.size
                }
                .onChange(of: geometry.size) { newSize in
                    self.screenSize = newSize
                    scrW = screenSize.width
                    screenHeight = screenSize.height
                }
            HStack{
//                Spacer()
//                    .frame(width: horizontalPadding, height: screenHeight, alignment: .trailing)
//                    .background(backgroundColor)
                VStack{
                    
                    Spacer(minLength: 100)
                    
                    HStack{
                        Spacer()
                            .frame(width: 70, height: 20, alignment: .trailing)
                        Text("  INPUT: " + viewModel.currentInput)
                            .font(.title3)
                            .foregroundColor(.black)
                            .frame(width: keyboardWidth-kHeight-hSpace, height: kHeight, alignment: .leading)
                            .background(.white)
                        
                        Button(action: {viewModel.print1(str: scrW)}){
                            Text("📣")
                                .font(.system(size:40))
                                .frame(width: kHeight, height: kHeight, alignment: .center)
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
                        
                        .frame(width: 30, height: kHeight, alignment: .topTrailing)
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
                            VStack{
                                LazyVGrid(columns:columnArray, spacing:vSpace){
                                    ForEach(viewModel.keys){ key in
                                        keyView(key: key.content,
                                                keyWidth:kWidth,
                                                keyHeight:kHeight)
                                        .onTapGesture{
                                            viewModel.processKey(label:key)
                                        }
                                    }
                                    .padding(.horizontal, horizontalPadding/3)
                                }
                                .frame(width: keyboardWidth-kWidth-hSpace)
                                
                                Text("Custom Phrases (enter in settings)")
                                ForEach(viewModel.custPhrases) { phrase in
                                    if (phrase.title != ""){
                                        keyView(key: phrase.title,
                                                keyWidth: calcNumberOfColumns(scrW: screenSize.width)*kWidth+100,
                                                keyHeight:kHeight)
                                        .onTapGesture{
                                            viewModel.processSep(value:phrase.title)
                                        }
                                    }
                                }
                                Spacer(minLength: screenHeight/4)
                            }
                        }
                        
                        Spacer()
                            .frame(width: 10)
                        VStack{
                            Button(action: {viewModel.processSep(value:"spc")}){
                                Text("spc")
                                    .font(.system(size:20))
                                    .foregroundStyle(.black)
                                    .frame(width: kWidth, height: kHeight, alignment: .center)
                                    .background(.white)
                            }
                            Button(action: {viewModel.processSep(value: "⇧")}){
                                Text("⇧")
                                    .font(.system(size:20))
                                    .foregroundStyle(.black)
                                    .frame(width: kWidth, height: kHeight , alignment: .center)
                                    .background(.white)
                            }
                            Button(action: {viewModel.processSep(value: "⌫")}){
                                Text("⌫")
                                    .font(.system(size:20))
                                    .foregroundStyle(.black)
                                    .frame(width: kWidth, height: kHeight , alignment: .center)
                                    .background(.white)
                            }
                            
                            Button(action: {viewModel.processSep(value: "🗑")}){
                                Text("🗑")
                                    .font(.system(size:20))
                                    .frame(width: kWidth, height: kHeight , alignment: .center)
                                    .background(.white)
                            }
                            Spacer(minLength: 10)
                                .frame(width: kWidth, height: 20, alignment: .center)
                                .foregroundStyle(.black)
                                .background(backgroundColor)
                            //                        .frame(width: inputWidth, height: inputHeight * 0.8, alignment: .center)
                        }
                        .frame(width: kWidth, height: screenHeight * 0.75, alignment: .top)
                    }
                    .frame(width:keyboardWidth,height: screenHeight * 0.75, alignment: .top)
                    
                    .padding()
                    
                }
                
                
                Spacer()
                    .frame(width: horizontalPadding, height: screenHeight, alignment: .trailing)
                    .background(backgroundColor);
                
            }
            .background(backgroundColor);
        }
    }
}
   

func calcNumberOfColumns(scrW: CGFloat)->CGFloat{
    if (Int(scrW) < minSWidth) {
        return (scrW + hSpace)/(minKWidth+hSpace)
    } else  {
        return 12.0;
    }
}

func calcKWidth(scrW: CGFloat) -> CGFloat{
    if (Int(scrW) < minSWidth) {
        return CGFloat(minKWidth)
    } else if (Int(scrW) > maxSWdith){
        return CGFloat(maxKWdith)
    } else {
        return(scrW - 10*hSpace)/calcNumberOfColumns(scrW: scrW)
    }
}
func makeColumnArray(scrW: CGFloat)->[GridItem]{
    var columnArray:[GridItem] = []
    
    for _ in 0..<(Int(calcNumberOfColumns(scrW: scrW))-3){
        columnArray.append(GridItem())
    }
    
    return columnArray
}

func calcKeyBoardWidth(scrW: CGFloat) -> CGFloat {
    let kWidth = calcKWidth(scrW: scrW) // Get dynamic key width
    let hSpace: CGFloat = 28.0                      // Horizontal space between keys
    
    let numberOfColumns = calcNumberOfColumns(scrW: scrW)
    
    // Calculate the total width by multiplying number of columns by key width and adjusting for spacing
    return (numberOfColumns - 2) * kWidth + (numberOfColumns - 3) * hSpace - kWidth
}

struct keyView: View {
    
    let key: String
    
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
            Text(key)
                .font(.system(size: 22))
                .foregroundColor(textColor)
        }
        .frame(width:keyWidth, height:keyHeight)
    }
}

struct Settings : View  {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = abcTextViewModel.shared
    
    @State private var screenSize: CGSize = UIScreen.main.bounds.size
    
    var body: some View {
        GeometryReader { geometry in
            var scrW = geometry.size.width
            var screenHeight = geometry.size.height
            
            // Dynamically update screenSize state to trigger layout updates on rotation
            Color.clear
                .onAppear {
                    self.screenSize = geometry.size
                }
                .onChange(of: geometry.size) { newSize in
                    self.screenSize = newSize
                    scrW = screenSize.width
                    screenHeight = screenSize.height
                }
            
            ZStack(alignment: .topLeading) {
                Color(UIColor.lightGray)
                    .opacity(0.2)
                    .edgesIgnoringSafeArea(.all)
                
                
                VStack{
                    Spacer()
                        .frame(width: scrW, height: 20, alignment: .center)
                    HStack{
                        Text("Welcome " + (currUser.firstname ?? ""))
                            .frame(width:scrW*0.22, height: 20, alignment: .bottomLeading)
                        Spacer()
                            .frame(width:scrW*0.52, height: 20, alignment: .bottomTrailing)
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .font(.title)
                                .padding(40)
                        })
                    }
                    .frame(width:scrW*0.8, height: 30, alignment: .leading)
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
                    .frame(width:scrW*0.8, height: 20, alignment: .leading)
                    Text("Customize phrases")
                        .frame(width:scrW*0.8, height: 20, alignment: .leading)
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
                .frame(width:scrW*0.8, height: screenHeight, alignment: .center)
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

