//
//  String+isNumber.swift
//  SmartCity
//
//  Created by Michael on 12.03.19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit

extension String  {
    func isNumber() -> Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
