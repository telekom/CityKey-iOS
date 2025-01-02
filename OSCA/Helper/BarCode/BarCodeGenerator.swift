//
//  BarCode.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 03.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

// this is the format of the encoding  result:
// an instruction how to draw the bars
// wide = 3 pixels (black or white),
// narrow = 1 pixel (black or white
// [.wide, .narrow, .narrow, wide] translates to
// [ black, black, black, white, black, white, white, white]
typealias BarCode = [BarPixelColor]

enum BarPixelColor: Int {
    case black = 1
    case white = 0
    
    func flip() -> BarPixelColor {
        return self == .white ? .black : .white
    }
}

protocol BarCodeGenerating {
    func encode(_ barCodeString: String) -> BarCode?
}

private enum Bar: Int {
    case wide = 3
    case narrow = 1
}

// a conversion of the String input, e.g. "91021052"
// to an array to work with: [ [9,1], [0,2] [1,0], [5,2]]
private typealias PairedBarCodeArray = [PairedNumbers]

private struct PairedNumbers {
    let first: Int
    let second: Int
}

class BarCodeGenerator: BarCodeGenerating {
    
    private static let maximumCodeLength = 10
    
    // All collections as dictionaries for better error handling, nil vs index out of range
    private let patterns: [Int: [Int: Bar]] = [
        0: [1: .narrow, 2: .narrow, 3: .wide, 4: .wide, 5: .narrow],
        1: [1: .wide, 2: .narrow, 3: .narrow, 4: .narrow, 5: .wide],
        2: [1: .narrow, 2: .wide, 3: .narrow, 4: .narrow, 5: .wide],
        3: [1: .wide, 2: .wide, 3: .narrow, 4: .narrow, 5: .narrow],
        4: [1: .narrow, 2: .narrow, 3: .wide, 4: .narrow, 5: .wide],
        5: [1: .wide, 2: .narrow, 3: .wide, 4: .narrow, 5: .narrow],
        6: [1: .narrow, 2: .wide, 3: .wide, 4: .narrow, 5: .narrow],
        7: [1: .narrow, 2: .narrow, 3: .narrow, 4: .wide, 5: .wide],
        8: [1: .wide, 2: .narrow, 3: .narrow, 4: .wide, 5: .narrow],
        9: [1: .narrow, 2: .wide, 3: .narrow, 4: .wide, 5: .narrow]
    ]
    
    private let numericPatternLength = 5
    
    private let startPattern: [Bar] = [.narrow, .narrow, .narrow, .narrow]
    private let endPattern: [Bar] = [.wide, .narrow, .narrow]
    
    public func encode(_ barCodeString: String) -> BarCode? {
        // two numbers of the numeric code are getting interleaved with each other
        // so we convert and pair them first:
        let pairedBarCode = self.convert(barCodeString: barCodeString)
        
        guard pairedBarCode.count > 0 else {
            debugPrint("BarCodeGenerator: something went wrong during converting", barCodeString)
            return nil
        }

        // begin with the start pattern
        var result = self.appendPattern(self.startPattern, to: BarCode(), startPixelColor: .black)
        
        // iterating the number pairs
        for pairedNumbers in pairedBarCode {
            
            guard let firstNumberPattern = self.patterns[pairedNumbers.first],
                let secondNumberPattern = self.patterns[pairedNumbers.second] else {
                    debugPrint("BarCodeGenerator: no pattern found for numbers:", pairedNumbers, "in", self.patterns)
                    return BarCode()
            }
            
            var encodedPattern: [Bar] = [Bar]()
            
            for barPosition in (1...(numericPatternLength)) {
                
                guard let firstBar = firstNumberPattern[barPosition],
                    let secondBar = secondNumberPattern[barPosition] else {
                        debugPrint("BarCodeGenerator: no bar found in patterns:", firstNumberPattern, secondNumberPattern, "at", barPosition)
                        return BarCode()
                }
                
                encodedPattern.append(firstBar)
                encodedPattern.append(secondBar)
            }
            result = self.appendPattern(encodedPattern, to: result, startPixelColor: .black)
        }
        
        result = self.appendPattern(self.endPattern, to: result, startPixelColor: .black)
        
        return result
    }
    
    private func appendPattern(_ pattern: [Bar], to result: BarCode, startPixelColor: BarPixelColor) -> BarCode {
        
        var pixelColor = startPixelColor
        var newResult = result
        
        // translating the bar width into actual colored pixels
        for bar in pattern {
            for _ in (1...bar.rawValue) {
                newResult.append(pixelColor)
            }
            pixelColor = pixelColor.flip() // flip color after each Bar, important detail
        }
        return newResult
    }
    
    private func convert(barCodeString: String) -> PairedBarCodeArray {
        var returnArray = PairedBarCodeArray()
        
        if self.isBarCodeStringConvertable(barCodeString) {

            let lastIndex = barCodeString.count - 1
            
            for offset in stride(from: 0, to: lastIndex, by: 2) {
                if let pairedNumbers = self.getPairedNumbers(at: offset, from: barCodeString) {
                    returnArray.append(pairedNumbers)
                }
            }
        }
        return returnArray
    }
    
    private func getPairedNumbers(at offset: Int, from barCodeString: String) -> PairedNumbers? {
        // get the indices as safe as possible
        guard let firstIndex = barCodeString.index(barCodeString.startIndex, offsetBy: offset, limitedBy: barCodeString.endIndex),
            let secondIndex = barCodeString.index(barCodeString.startIndex, offsetBy: offset + 1, limitedBy: barCodeString.endIndex) else {
                debugPrint("BarCodeGenerator: something terribly wrong in barcode content:", barCodeString, "contentCount:", barCodeString.count)
                return nil
        }
        
        guard let numberOne = Int(String(barCodeString[firstIndex])),
            let numberTwo = Int(String(barCodeString[secondIndex])) else {
                debugPrint("BarCodeGenerator: non numeric char detected in ", barCodeString)
                return nil
        }
        
        return PairedNumbers(first: numberOne, second: numberTwo)
    }
    
    private func isBarCodeStringConvertable(_ barCodeString: String) -> Bool {
        // check if content.length is dividable by 2
        guard barCodeString.count % 2 == 0 else {
            debugPrint("BarCodeGenerator: barCodeString not even", barCodeString)
            return false
        }
        // check if length too long
        guard barCodeString.count <= BarCodeGenerator.maximumCodeLength else {
            debugPrint("BarCodeGenerator: barCodeString too large:", barCodeString.count, "maximum is", BarCodeGenerator.maximumCodeLength)
            return false
        }
        // check if content is numeric
        guard Int(barCodeString) != 0 && Int(barCodeString) != nil else {
            debugPrint("BarCodeGenerator: barCodeString not numeric", barCodeString)
            return false
        }
        
        return true
    }
}

// For Documentation: this is the "pure" algorithm
/*
public boolean[] encode(String contents) {
    int length = contents.length();
    if (length % 2 != 0) {
        throw new IllegalArgumentException("The length of the input should be even");
    }
    if (length > 80) {
        throw new IllegalArgumentException(
            "Requested contents should be less than 80 digits long, but got " + length);
    }
    
    checkNumeric(contents);
    
    boolean[] result = new boolean[9 + 9 * length];
    int pos = appendPattern(result, 0, START_PATTERN, true);
    for (int i = 0; i < length; i += 2) {
        int one = Character.digit(contents.charAt(i), 10);
        int two = Character.digit(contents.charAt(i + 1), 10);
        int[] encoding = new int[10];
        for (int j = 0; j < 5; j++) {
            encoding[2 * j] = PATTERNS[one][j];
            encoding[2 * j + 1] = PATTERNS[two][j];
        }
        pos += appendPattern(result, pos, encoding, true);
    }
    appendPattern(result, pos, END_PATTERN, true);
    
    return result;
}
*/

/*
 protected static int appendPattern(boolean[] target, int pos, int[] pattern, boolean startColor) {
 
 boolean color = startColor;
 
 int numAdded = 0;
 
 for (int len : pattern) {
 
 for (int j = 0; j < len; j++) {
 
 target[pos++] = color;
 
 }
 
 numAdded += len;
 
 color = !color; // flip color after each segment
 
 }
 
 return numAdded;
 
 }

 */

