//
//  SCPasswordCheck.swift
//  SmartCity
//
//  Created by Michael on 26.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCPasswordCheck: NSObject {

    static func passwordMinCharReached(pwd : String) -> Bool{
        return pwd.count >= 8
    }
    
    static func passwordContainsSymbol(pwd : String) -> Bool{
        return pwd.containsSpecialCharacter()
    }

    static func passwordStructureValid(pwd : String) -> Bool{
        return SCPasswordCheck.passwordContainsSymbol(pwd: pwd) && SCPasswordCheck.passwordMinCharReached(pwd : pwd) && SCPasswordCheck.passwordContainsDigit(pwd: pwd)
    }
    
    static func passwordContainsDigit(pwd: String) -> Bool {
        return pwd.containsDigit()
    }

}
