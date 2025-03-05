/*
Created by Michael on 11.05.20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

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
