//
//  ContentView.swift
//  abcText2Speech
//
//  Created by Jaanvi Chirimar on 3/26/23.
//

import UIKit
import SwiftUI

var hSpace = 22.0
var vSpace = 16.0
var keyColor = Color.white
var textColor = Color.black

var backgroundColor = Color(red:220/255.0,green:220/255.0, blue:220/255.0)

let minKWidth = 32.0; //TEST VAR 2
let maxKWdith = 64.0; //TEST VAR

let minSWidth = 512; //TEST VAR
let maxSWdith = 1600; //TEST VAR


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
    var currentUser = currUser
    
    var kHeight: CGFloat { kWidth*1.2 }// 48.0 matches minimm value of kWidth

    init(){
        //JC-TODO - Handle custom phrases
        viewModel.phrasesDict[abcTextViewModel.phrases[1]] = "My name is " + (currentUser.firstname ?? "")
        viewModel.modelABCTextModel = abcTextViewModel.createABCText(qwertyFlag: false, phrasesDictLocal: viewModel.phrasesDict)
        currentUser = currUser

    }
    
    var body: some View {

        GeometryReader { geometry in
            var scrW = geometry.size.width
            var screenHeight = geometry.size.height
            
            // Dynamically update screenSize state to trigger layout updates on rotation
            Color.clear
                .onAppear {
                    self.screenSize = geometry.size
                    scrW = screenSize.width
                    screenHeight = screenSize.height
                }
                .onChange(of: geometry.size) { newSize in
                    self.screenSize = newSize
                    scrW = screenSize.width
                    screenHeight = screenSize.height
                }
            
            HStack( alignment: .bottom, spacing:0){
                Spacer()
                    .frame(width: kWidth, height: screenHeight*1, alignment: .topLeading)
                    //.background(.purple);
                
                VStack(spacing:0){
                    let keyboardHeight = screenHeight - (20 + 20 + 40 + kHeight)
                    
                    Spacer()
                        .frame(width:keyboardWidth, height:10)
                        //.background(.orange)
                    
                    gearRow(gearKey:viewModel.modelABCTextModel.gearKey, keyboardWidthInput: keyboardWidth, heightInput: 30)
                        //.background(.red)
                    
                    inputRow(viewModelInput: viewModel, keyboadWidthInput: keyboardWidth, keyHeightInput: kHeight, hSpaceInput: hSpace)
                    
                    correctionsAndMisspellings(viewModelInput: viewModel)
                        .frame(width:keyboardWidth, height:40)
                                        
                    HStack(alignment:.top, spacing:14) {
                        let xy = scrollBarShow(width:keyboardWidth-kWidth-hSpace-8, height:0.9*keyboardHeight)
                        ScrollView(){
                            VStack(){
                                createKeyBoards(viewModelInput: viewModel, columnArrayInput:columnArray,
                                                vSapceInput: vSpace, kWidthInput: kWidth, kHeightInput: kHeight)
                                
                                createCustomPhrases()
                                
                                showCustomPhrases(scrWInput: scrW)
                                
                                Spacer(minLength: screenHeight/5)
                            }
                            .frame(width: keyboardWidth-kWidth-hSpace, alignment: .leading)

                        }//row for letters and custom phrasese.
                        .background(xy)
                                                
                        createControlKeys(viewModelInput: viewModel, screenHeightInput: screenHeight,
                                          kWidthInput:kWidth+5, kHeightInput: kHeight)
                    }
                    .frame(width:keyboardWidth, height: keyboardHeight, alignment: .top)
                    //.background(.gray)
                }
                //.background(.blue)
                
                Spacer()
                    .frame(width: kWidth, height: screenHeight * 0.1, alignment: .topLeading)
                    //.background(.yellow);
            }
            .frame(alignment: .top)
            .background(backgroundColor);
        }
    }
    
    /*
     * Return view:
     * Gear symbol to the right of INPUT.
     */
    func gearRow(gearKey:String, keyboardWidthInput:Double, heightInput:Double)-> some View {
        HStack(alignment:.top, spacing:45){
            Spacer()
                .frame(width: keyboardWidthInput, height: heightInput)
            
            Button(action: {
                showSettings = true
            }, label: {
                Label("", systemImage: gearKey)
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
            .frame(width:heightInput, height:heightInput)
        }
        .frame(width:keyboardWidthInput, height: heightInput)
    }

    /*
     * Return view:  INPUT: text area where input is made Speaker Button that converts text to voice.
     * Gear symbol to the right of INPUT. JC-TODO. Gear should be a different function since it is
     * logically different from the input.
     */
    func inputRow(viewModelInput:abcTextViewModel, keyboadWidthInput: Double,
                  keyHeightInput:Double, hSpaceInput:Double)-> some View {
        HStack(alignment:.top, spacing:21){
            Text(viewModelInput.modelABCTextModel.inputLabelKey + viewModelInput.currentInput)
                .font(.title3)
                .foregroundColor(.black)
                .frame(width:keyboadWidthInput-keyHeightInput-hSpaceInput,
                       height:keyHeightInput, alignment:.leading)
                .background(.white)
            
            Button(action: {viewModelInput.text2Speech()}){
                keyView(key:viewModelInput.modelABCTextModel.speakerKey, keyWidth:keyHeightInput, keyHeight:keyHeightInput)
            }
                    }
        .frame(width:keyboadWidthInput, height:keyHeightInput, alignment:.topLeading)
    }
    
    
    func suggestions(viewModelInput:abcTextViewModel , guessArray:Array<String>) -> some View {
        let startIndex = viewModelInput.currentInput.startIndex;
        let endIndex = viewModelInput.currentInput.endIndex;
        return ForEach(Array(guessArray.prefix(3)), id: \.self) { suggestion in
            Text(suggestion)
                .onTapGesture {
                    if let index = viewModelInput.currentInput.index(endIndex, offsetBy: -viewModelInput.currentWord.count, limitedBy: startIndex) {
                        viewModelInput.currentInput = String(viewModelInput.currentInput[..<index]) + suggestion + " "
                        viewModelInput.currentWord = ""
                        
                    }
                }
        }
    }
    
    func correctionsAndMisspellings(viewModelInput:abcTextViewModel)->some View{
        let textChecker = UITextChecker()
        let completions = textChecker.completions(
            forPartialWordRange: NSRange(0..<viewModelInput.currentWord.utf16.count),
            in: viewModelInput.currentWord,
            language: "en_US"
        )
        let misspelledRange =
        textChecker.rangeOfMisspelledWord(in: viewModelInput.currentWord,
                                          range: NSRange(0..<viewModelInput.currentWord.utf16.count),
                                          startingAt: 0,
                                          wrap: false,
                                          language: "en_US")
        
        if misspelledRange.location != NSNotFound {
            let guesses = textChecker.guesses(forWordRange: misspelledRange,
                                              in: viewModelInput.currentWord,
                                              language: "en_US")?.prefix(3)
            return AnyView(HStack{
                if completions != nil {
                    suggestions(viewModelInput: viewModelInput, guessArray: (completions!))
                }
                
                if guesses != nil {
                    suggestions(viewModelInput: viewModelInput, guessArray: Array(guesses!))
                }
            })
        } else {
            return AnyView(HStack{
                Text("No suggestions found.")
            })
        }
    }

    func createKeyBoards(viewModelInput:abcTextViewModel, columnArrayInput:[GridItem], vSapceInput:Double, kWidthInput:Double, kHeightInput:Double)-> some View{
        let tempKeyContentArray = [viewModelInput.keys.map {$0.content},
                                   viewModelInput.punctuationKeys.map {$0.content},
                                   viewModelInput.numKeys.map {$0.content},
                                   viewModelInput.phraseKeys.map {$0.content}]
        
        return ForEach(tempKeyContentArray, id:\.self){
            contentArray in
            gridMeta(columnArrayInput:columnArrayInput, keysArray: contentArray, vSpaceInput: vSapceInput, kWidthInput: kWidthInput, kHeightInput: kHeightInput)
            Spacer()
                .frame(height: vSapceInput+5)
        }
    }
    
    /*
     * Return view:  Creates a grib of buttons based on keysArray
     * Used to create grids for alphabets, punctations, numbers, and system phrases.
     */
    func gridMeta(columnArrayInput:[GridItem], keysArray:[String],
                  vSpaceInput:Double, kWidthInput:Double, kHeightInput:Double)-> some View {
        LazyVGrid(columns:columnArrayInput, alignment:.leading, spacing:vSpaceInput){
            ForEach(keysArray, id:\.self){ key in //The default keys are unique
                keyView(key: key,
                        keyWidth:kWidthInput,
                        keyHeight:kHeightInput)
                .onTapGesture{
                    viewModel.processKey(label:key)
                }
            }
        }
    }
    
    func createCustomPhrases()-> some View{
        HStack{
            Text("Custom Phrases")
            Button(action: {
                showSettings = true
                
            }, label: {
                Label("", systemImage: "plus.circle")
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
        }
    }
    
    func showCustomPhrases(scrWInput:CGFloat)-> some View{
        ForEach(viewModel.custPhrases) { phrase in
            if (phrase.title != ""){
                keyView(key: phrase.title,
                        keyWidth: calcNumberOfColumns(scrW: scrWInput)*kWidth+100,
                        keyHeight:kHeight)
                .onTapGesture{
                    viewModel.processKey(label:phrase.title)
                }
            }
        }
    }
    
    /*
     * Return view:  Contorl buttons on the right side.
     * Space, Delete, Uppercase, and Clear
     */
    func createControlKeys(viewModelInput:abcTextViewModel, screenHeightInput:CGFloat, kWidthInput: Double,
                           kHeightInput:Double)-> some View{
        let contentArray = viewModelInput.modelABCTextModel.controlKeys.map {$0.content}
        return VStack(spacing:12){
            ForEach(contentArray, id:\.self){ key in //The default keys are unique
                keyView(key: key,
                        keyWidth:kWidthInput,
                        keyHeight:kHeightInput)
                .onTapGesture{
                    viewModelInput.processKey(label:key)
                }
            }
        }
    }
}
   
struct scrollBarShow: View {
    var width:Double
    var height:Double
    var body: some View{
        Rectangle()
            .fill(Color(UIColor(red: 1, green: 1, blue: 1, alpha: 0)))
            .frame(width: width, height: height, alignment: .top)
            .overlay(Divider().background(.black),alignment: .trailing)
    }
}

func calcNumberOfColumns(scrW: CGFloat)->CGFloat{
    if (Int(scrW) < minSWidth) {
        return (scrW+3*hSpace)/(minKWidth+hSpace)
    } else  {
        return 12.0;
    }
}

func calcKWidth(scrW: CGFloat) -> CGFloat{
    let colNum = calcNumberOfColumns(scrW: scrW)
    if (Int(scrW) < minSWidth) {
        hSpace = 18.0
        vSpace = 12.0
        return CGFloat(minKWidth)
    } else if (Int(scrW) > maxSWdith){
        return CGFloat(maxKWdith)
    } else {
        if (((scrW - (colNum-3)*hSpace)/colNum) < minKWidth) {
            return minKWidth
        } else {
            return(scrW - (colNum-3)*hSpace)/colNum
        }
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
    let kWidth = calcKWidth(scrW: scrW)
    let numberOfColumns = calcNumberOfColumns(scrW: scrW)
    
    // total width by multiplying number of columns by key width and adjusting for spacing
    return (numberOfColumns - 2) * kWidth + (numberOfColumns - 3) * hSpace
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
                backgroundColor
                    .opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                
                VStack{
                    Spacer()
                        .frame(width: scrW, height: 20, alignment: .center)
                    HStack{
                        Text("Welcome " + (currUser.firstname ?? ""))
                            .frame(width:scrW*0.3, height: 20, alignment: .bottomLeading)
                        Spacer()
                            .frame(width:scrW*0.6, height: 20, alignment: .bottomTrailing)
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
                        viewModel.qwertyFlag.toggle()
                        if(viewModel.qwertyFlag){
                            viewModel.modelABCTextModel = abcTextViewModel.createABCText(qwertyFlag: true, phrasesDictLocal: viewModel.phrasesDict)
                        } else{
                            viewModel.modelABCTextModel = abcTextViewModel.createABCText(qwertyFlag: false, phrasesDictLocal: viewModel.phrasesDict)
                        }
                        
                    }){
                        if (viewModel.qwertyFlag){
                            Text("Click to switch to ABC");
                        } else {
                            Text("Click to switch to QWERTY");
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
                        } label: {
                            Text("SAVE")
                        }
                    }
                }
                .frame(width:scrW, height: screenHeight, alignment: .center)
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


