//
//  KeychainHelper.swift
//  OSCA
//
//  Created by Bhaskar N S on 19/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import KeychainSwift

protocol KeychainUsable {
    func save(key: String, value: String?)
    func load(key: String) -> String?
    func clear()
}

class KeychainHelper: KeychainUsable {
    private let widgetUtility: WidgetUtility
    
    init(widgetUtility: WidgetUtility = WidgetUtility()) {
        self.widgetUtility = widgetUtility
    }
    
    func save(key: String, value: String?) {
        guard let token = value else { return }
        let keychain = KeychainSwift()
        keychain.accessGroup = widgetUtility.getKeychainAccessGroup()
        keychain.set(token, forKey: key, withAccess: .accessibleAfterFirstUnlock)
    }
    
    func load(key: String) -> String? {
        let keychain = KeychainSwift()
        keychain.accessGroup = widgetUtility.getKeychainAccessGroup()
        return keychain.get(key)
    }
    
    func clear() {
        let keychain = KeychainSwift()
        keychain.accessGroup = widgetUtility.getKeychainAccessGroup()
        keychain.clear()
    }
}
