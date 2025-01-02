//
//  SCInputValidation.swift
//  OSCA
//
//  Created by Michael on 11.05.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

enum SCInputValidationFirstPwdResult {
    case sameAsEMail
    case strong
    case tooWeak
    case empty
}

enum SCInputValidationSecondPwdResult {
    case pwdsAreDifferent
    case pwdsAreMatching
    case empty
}

class SCInputValidation {

    static func isInputValid(_ input: String, fieldType: SCTextfieldComponentType) -> SCValidationResult {
        switch fieldType {
            
        case .email:
            return self.validateEmail(input)
        case .newPassword:
            return self.validatePassword(input)
        case .birthdate:
            return self.validateBirthdate(input)
        case .postalCode:
            return self.validatePostalCode(input)
        case .text:
            return self.validateText(input)
            
        default:
            debugPrint("fieldType not yet supported:", fieldType)
            return SCValidationResult(isValid: false, message: nil)
        }
    }

    static func validateFirstPassword(_ firstPwd : String, email : String) -> SCInputValidationFirstPwdResult {
        
        if firstPwd.isEmpty{
            return .empty
        }

        if  firstPwd == email && !email.isEmpty{
            return .sameAsEMail
        }
        
        if (!self.passwordContainsSymbol(pwd: firstPwd) || !self.passwordMinCharReached(pwd: firstPwd) || !self.passwordContainsDigit(pwd: firstPwd)) {
            return .tooWeak
        } else {
            return .strong
        }
    }

    static func validateSecondPassword(_ secondPwd : String, firstPwd : String) -> SCInputValidationSecondPwdResult {
        if secondPwd.isEmpty{
            return .empty
        }

        if firstPwd == secondPwd {
            return .pwdsAreMatching
        } else {
            return .pwdsAreDifferent
        }
    }
    
    static func validateEmail(_ email: String) -> SCValidationResult {
        // We do no email validation in client side
        if !email.isEmpty {
            if email.isEmail() {
                return SCValidationResult(isValid: true, message: nil)
            } else {
                return SCValidationResult(isValid: false, message: "r_001_registration_error_incorrect_email".localized())
            }
        } else {
            return SCValidationResult(isValid: false, message: "r_001_registration_error_empty_field".localized())
        }
    }
    
    static func validatePassword(_ pwd: String) -> SCValidationResult {
        if pwd.count > 0 {
            return SCValidationResult(isValid: true, message: nil)
        } else {
            return SCValidationResult(isValid: false, message: "r_001_registration_error_empty_field".localized())
        }
    }
    
    static func validateBirthdate(_ dateString: String) -> SCValidationResult {
        let components = dateString.split(separator: ".")
        guard components.count == 3 else {
            if dateString.count > 10 {
                return SCValidationResult(isValid: true, message: nil)
            } else {
                return SCValidationResult(isValid: false, message: "r_001_registration_error_empty_field".localized())
            }
        }
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = Array((1900...currentYear).reversed())

        let day = Int(components[0]) ?? 0
        let month = Int(components[1]) ?? 0
        let year = Int(components[2]) ?? 0
        
        if (day > 0 && day <= 31) &&
            (month > 0 && month <= 12) &&
            (year >= 1920 && year <= years.first ?? 0) {
            return SCValidationResult(isValid: true, message: nil)
        } else {
            return SCValidationResult(isValid: false, message: "r_001_registration_error_empty_field".localized())
        }
    }
    
    static func validatePostalCode(_ postalCode: String) -> SCValidationResult {
        
        if !postalCode.isEmpty {
            if postalCode.count == 5 {
                return SCValidationResult(isValid: true, message: nil)
            } else {
                return SCValidationResult(isValid: false, message: "r_001_registration_error_incorrect_postcode".localized())
            }
        } else  {
            return SCValidationResult(isValid: false, message: "r_001_registration_error_empty_field".localized())
        }
    }
    
    static func validateText(_ text: String) -> SCValidationResult {
        if text.count > 0 {
            return SCValidationResult(isValid: true, message: nil)
        } else {
            return SCValidationResult(isValid: false, message: "r_001_registration_error_empty_field".localized())
        }
    }

    static func isPwdString(_ pwd1: String, startingWith pwd2: String ) -> Bool{
        let startPWD1 = pwd1.prefix(pwd2.count)
        return startPWD1 == pwd2
    }
    
    static func passwordMinCharReached(pwd: String) -> Bool {
        return pwd.count >= 8
    }
    
    static func passwordContainsSymbol(pwd: String) -> Bool {
        return pwd.containsSpecialCharacter()
    }
    
    static func passwordContainsDigit(pwd: String) -> Bool {
        return pwd.containsDigit()
    }
    
    static func passwordContainsSpace(pwd: String) -> Bool {
        return pwd.containsSpace()
    }

}
