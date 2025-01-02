//
//  String+containsSpecialCharacter.swift
//  SmartCity
//
//  Created by Michael on 11.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit

extension String {
    func containsSpecialCharacter() -> Bool {
        let characters = Array(self)
        for character in characters {
            if (!character.isLetter && !character.isNumber) { return true } 
        }
        return false
    }
    
    func containsDigit() -> Bool {
        let characters = Array(self)
        for character in characters {
            if character.isNumber { return true }
        }
        return false
    }
    
    func containsSpace() -> Bool {
        let regex = ".*[[:space:]].*"
        let testString = NSPredicate(format: "SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    func isSpaceOrEmpty() -> Bool{
        return self.trimmingCharacters(in: .whitespaces).isEmpty ? true : false
    }
}
