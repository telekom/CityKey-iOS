//
//  String+Localized.swift
//  SmartCity
//
//  Created by Michael on 24.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 *
 * Extension that supports a convenience way to localize strings
 *
 */
extension String {
    func localized() -> String {
        return self.localized(comment: "")
    }
    
    func localized(comment:String) -> String {
        let localizedString = NSLocalizedString(self, tableName: "Localization", bundle: .main, value:"\(self)", comment:comment)
        return localizedString.replacingOccurrences(of: "\\n", with: "\n").replacingOccurrences(of: "\\'", with: "'")
    }

    /// Work around for localied string. Due to POEditor contains %s in localized strings which is supported by Android.
    /// - Returns: string with formatted argument contains %@
    func replaceStringFormatter() -> String {
        return self.replacingOccurrences(of: "%s", with: "%@")
    }
}
