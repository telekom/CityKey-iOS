//
//  SCDeviceUniqueID.swift
//  OSCA
//
//  Created by A118572539 on 03/01/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDeviceUniqueID {
    
    static let shared = SCDeviceUniqueID()
    
    private var uuID: String = ""
    
    private init() {}
    
    public func saveUniqueIDIfNeeded() {
        if UserDefaults.standard.value(forKey: "deviceID") == nil {
            uuID = UUID().uuidString
            UserDefaults.standard.set(uuID, forKey: "deviceID")
        }
    }
    
    public func getDeviceUniqueID() -> String? {
        return UserDefaults.standard.value(forKey: "deviceID") as? String
    }
}
