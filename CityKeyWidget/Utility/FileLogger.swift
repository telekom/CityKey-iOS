/*
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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/
//
//  FileLogger.swift
//  SCWidgetExtension
//
//  Created by Bhaskar N S on 12/09/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

import UIKit

enum SCFileLoggerTag : String {
    case logout = "logout"
    case ausweis = "ausweis"
    case wasteCalendarWidget = "wasteCalendarWidget"
}

// SMARTC-18143 iOS : Implement Logging for login/logout functionality
class SCFileLogger {
    
    private let dateFormatter = DateFormatter()
    static let shared = SCFileLogger()
    
    init() {
        dateFormatter.dateFormat = "y-MM-dd H:m:ss.SSSS"
    }
    
    func fileURL(forTag tag: SCFileLoggerTag) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)
        let documentDirectoryPath = paths.first!
        let log = documentDirectoryPath.appendingPathComponent("\(tag.rawValue)_log.txt")
        return log
    }
    
    
    #if RELEASE || STABLE
    func write(_ stringInput : String, withTag tag: SCFileLoggerTag) { }
    #else
    func write(_ stringInput : String, withTag tag: SCFileLoggerTag) {
        
        let string = "\(tag) | \(dateFormatter.string(from: Date())) | \(stringInput) \n\n\n\n"
        
        do {
            let handle = try FileHandle(forWritingTo: fileURL(forTag: tag))
            handle.seekToEndOfFile()
            handle.write(string.data(using: .utf8)!)
            handle.closeFile()
            
        } catch {
            
            print(error.localizedDescription)
            do {
                try string.data(using: .utf8)?.write(to: fileURL(forTag: tag))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    #endif
    
    
    func clearLog(withTag tag : SCFileLoggerTag) {
        try? FileManager.default.removeItem(at: fileURL(forTag: tag))
    }
    
    #if RELEASE || STABLE
    func presentShareActivity(forTag tag: SCFileLoggerTag) { }
    #else
    func presentShareActivity(forTag tag: SCFileLoggerTag) {
        
        if tag == .ausweis {
            presentAusweisLogShareActivity()
        } else {
            presentLogShareActivity(tag: tag)
        }
    }
    #endif
    
    private func presentLogShareActivity(tag : SCFileLoggerTag) {
        
        let shareActivityController = UIActivityViewController(activityItems: [SCFileLogger.shared.fileURL(forTag: tag)], applicationActivities: nil)
        shareActivityController.completionWithItemsHandler = { (activityType, status, items, error) -> Void in
            
            if status {
                self.clearLog(withTag: tag)
            }
        }
        
    }
    
        
    private func presentAusweisLogShareActivity() {
        
        var files = [SCFileLogger.shared.fileURL(forTag: .ausweis)]
        files.append(contentsOf: ausweisApp2sdkLogFiles())
        let finalFile = URL(fileURLWithPath: "\(NSTemporaryDirectory())eGovServiceLog_\(Date().description).txt")
        var stringBuffer = String()
        
        stringBuffer.append("Date & Time : \(Date().description)\n\n")
        
        for file in files {
            
            stringBuffer.append("\n\n File : \(file.lastPathComponent) \n\n")
            stringBuffer.append((try? String(contentsOf: file)) ?? "" )
            stringBuffer.append("\n\n ********************************************* \n\n")

        }
        
        try? stringBuffer.write(to: finalFile, atomically: true, encoding: .utf8)
        
        let shareActivityController = UIActivityViewController(activityItems: [finalFile], applicationActivities: nil)
        shareActivityController.completionWithItemsHandler = { (activityType, status, items, error) -> Void in

            if status == true {
                for f in files {
                    try? FileManager.default.removeItem(at: f)
                }
            }
        }
    }
    
    private func ausweisApp2sdkLogFiles() -> [URL] {
        
        var files = [URL]()
        if let tempFiles = try? FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) {
            
            for file in tempFiles{
                if file.contains("AusweisApp2") {
                    files.append(URL(fileURLWithPath: "\(NSTemporaryDirectory())\(file)"))
                }
            }
        }
        debugPrint("Ausweis Log Files : \(files)")
        return files
    }
    
}
