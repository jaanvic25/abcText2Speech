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
    
    let horizontalPadding = makePaddingHorizontal(horizontalSpacing:hSpace, keyWidth:inputWidth)
    
    
    var body: some View {
            VStack{
                Text("Input: [" + viewModel.getInputString() + "]")
                    .font(.title)
                    .padding()
                
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
