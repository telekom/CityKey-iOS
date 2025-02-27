/*
Created by Michael on 04.12.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit
import KeychainSwift
import WidgetKit

enum SCRefreshTokenState {
    case empty
    case valid
    case invalid
}

enum SCLogoutReason {
    case technicalReason
    case initiatedByUser
    case updateSuccessful
    case kmliNotChcked
    case wasNotLoggedInBefore
    case accountDeleted
    case invalidRefreshToken
}

protocol SCLoginAuthProviding {
    func isUserLoggedIn() -> Bool
    func login(name: String, password: String, remember: Bool,
               completion: @escaping (SCWorkerError?) -> ())
    func logoutReason() -> SCLogoutReason?
    func clearLogoutReason()
}

protocol SCAuthStateProviding {
    func isUserLoggedIn() -> Bool
}

protocol SCLogoutAuthProviding {
    func isUserLoggedIn() -> Bool
    func logout(logoutReason: SCLogoutReason, completion: @escaping ()->())
}

protocol SCAuthTokenProviding {
    func renewAccessTokenIfValid(completion: @escaping (_ result : Bool) ->())
    func isUserLoggedIn() -> Bool
    func fetchAccessToken(completion: @escaping (_ accessToken: String?, _ userID: String?, _ error: SCWorkerError? ) ->())
    func getRefreshToken() -> String?
}

protocol SCAuthConfirmationProviding {
    func confirmAuthorization(_for name: String, password: String, completion: @escaping (SCWorkerError?) -> ())
}

protocol SCAuthUserIDProviding {
    func set(userID: String)
}

class SCAuth : SCAuthStateProviding {
    // MARK: - public properties
    static let shared = SCAuth()
    
    public var worker: SCAuthorizationWorking!
    // these two must be injected after app start
    public var userContentWorker: (SCUserContentDeleting & SCUserContentUserIdentifing)? {
        didSet {
            // catch all USERID Changes
            self.userContentWorker?.observeUserID(completion: { [weak self ] (userID) in
                guard let weakSelf = self else { return }
                
                if let userID =  userID {
                    weakSelf.set(userID: userID)
                }
            })
        }
    }
    public var userCityContentWorker: (SCUserCityContentDeleting)?
    
    // MARK: - private properties
    private let refreshTokenKey = "RefreshTokenKey"
    private let accessTokenKey = "AccessTokenKey"
    private let accessTokenExpiresInKey = "AccessTokenExpiresInKey"
    private let refreshTokenExpiresInKey = "RefreshTokenExpiresInKey"
    private let authCreationTimeKey = "AuthCreationTimeKey"
    private let shouldRememberLoginKey = "ShouldRememberLoginKey"
    
    private var accessToken: String?
    
    private var shouldRememberLogin: Bool = false
    private var tempRefreshToken: String?
    
    private var refreshToken: String?
    private var userID: String?
    
    private var reasonForLogout: SCLogoutReason?
    
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: SCUtilities.getAppGroupId()) ?? UserDefaults.standard
    }
    
    private var refreshTokenExpiresIn: TimeInterval {
        get {
            return userDefaults.double(forKey: self.refreshTokenExpiresInKey)
        }
        set {
            userDefaults.set(newValue, forKey: self.refreshTokenExpiresInKey)
        }
    }
    
    private var accessTokenExpiresIn: TimeInterval {
        get {
            return userDefaults.double(forKey: self.accessTokenExpiresInKey)
        }
        set {
            userDefaults.set(newValue, forKey: self.accessTokenExpiresInKey)
        }
    }
    
    private var authCreationTime: TimeInterval {
        get {
            return userDefaults.double(forKey: self.authCreationTimeKey)
        }
        set {
            userDefaults.set(newValue, forKey: self.authCreationTimeKey)
        }
    }
    
    private let keychainHelper: KeychainUsable = KeychainHelper()
    
    // MARK: - init
    init() {
        
        self.shouldRememberLogin = self.loadShouldRememberLoginStatus()
        self.refreshToken = self.loadRefreshToken()

        debugPrint("inside SCAuth init() Refresh Token -> \(String(describing: refreshToken))")
        
        SCFileLogger.shared.write("inside SCAuth init() Refresh Token -> \(String(describing: refreshToken))", withTag: .logout)
    }
    
    // MARK: - Public
    public func isUserLoggedIn() -> Bool {
        SCFileLogger.shared.write("inside method isUserLoggedIn()", withTag: .logout)
        /// if we still have accessToken that means the app was not killed since we retrieved the token , so the session is still valid
        self.accessToken = loadToken(for: self.accessTokenKey)
        if self.accessToken != nil && couldAccessTokenBeValid() {
            SCFileLogger.shared.write("isUserLoggedIn() access token is not nil", withTag: .logout)
            return true
        }
        
        /// If shouldRememberLogin is false then user is logged in only if the last AT is still valid
        if self.shouldRememberLogin == false {
            SCFileLogger.shared.write("isUserLoggedIn() should remember login = false", withTag: .logout)
            if !couldAccessTokenBeValid() {
                SCFileLogger.shared.write("access token is not valid -> \(String(describing: accessToken))", withTag: .logout)
                return false
            }
        }

        /// if shouldRememberLogin is true then user is logged in only if the RT is valid ( RT is valid for 90 Days )
        let tokenState = self.refreshTokenState()
        SCFileLogger.shared.write("Refresh token state is \(tokenState)", withTag: .logout)
        switch tokenState {
        case .valid:
            return true
        case .empty, .invalid:
            return false
        }
    }
    
    public func hasUserStoredAccountData() -> Bool {
        return self.refreshToken != nil
    }
    
    public func logoutReason() -> SCLogoutReason? {
        return self.reasonForLogout
    }
    
    public func clearLogoutReason() {
        self.reasonForLogout = nil
    }
    
    
    // MARK: - Private
    public func removeAuthorization() {
        
        self.accessToken = nil
        self.refreshToken = nil
        self.accessTokenExpiresIn = 0
        self.refreshTokenExpiresIn = 0
        self.authCreationTime = 0
        self.shouldRememberLogin = false
        self.userID = nil
        self.storeAccessToken(token: nil)
        self.storeRefreshToken(token: nil)
        self.storeShouldRememberLoginStatus(status: false)
        SCUserDefaultsHelper.setUserID(self.userID ?? "-1")
        SCUserDefaultsHelper.clearProfileData()
        KeychainSwift().clear() // this is to clear tokens which saved in keychain without app groups
        keychainHelper.clear()
    }
    
    
    // MARK: the get token logic
    public func getNewAccessToken(completion: @escaping (_ accessToken: String? , _ userID: String?, _ error : SCWorkerError?) ->()) {
        // 2. Do we have a refreshToken stored?
        debugPrint("2. Do we have a refreshToken stored?")
        SCFileLogger.shared.write("2. Do we have a refreshToken stored?", withTag: .logout)
        
        guard let refreshToken = self.refreshToken else {
            // IF NO
            // 3. present a login Screen
            debugPrint("NO present a login Screen")
            SCFileLogger.shared.write("NO present a login Screen", withTag: .logout)
            self.demandUserAction(completion: completion)
            return
        }
        
        // IF YES -> could it be valid?
        debugPrint("YES -> could it be valid?")
        SCFileLogger.shared.write("YES -> could it be valid?", withTag: .logout)
        if self.refreshTokenState() == .invalid {
            // IF NO -> proceed with 3.
            debugPrint("NO -> proceed with 3.")
            SCFileLogger.shared.write("NO -> proceed with 3.", withTag: .logout)
            self.logout(logoutReason: .invalidRefreshToken, completion: {
                self.demandUserAction(completion: completion)
            })
            return
        }
        
        // IF YES -> request a new accessToken
        debugPrint("YES -> request a new accessToken")
        SCFileLogger.shared.write("YES -> request a new accessToken", withTag: .logout)
        
        self.requestNewAccessToken(with: refreshToken) { (newAccessToken, error) in
            
            if let accessToken = newAccessToken {
                // IF SUCCESS, deliver it -> COMPLETION
                debugPrint("IF SUCCESS, deliver it -> COMPLETION")
                SCFileLogger.shared.write("IF SUCCESS, deliver it -> COMPLETION", withTag: .logout)
                completion(accessToken, self.userID, nil)
            } else if let error = error  {
                
                
                switch error {
               
                case .unauthorized:
                    
                    debugPrint("IF FAILURE, proceed to 3.")
                    SCFileLogger.shared.write("IF FAILURE, proceed to 3.", withTag: .logout)
                    self.logout(logoutReason: .technicalReason, completion: {
                        self.demandUserAction(completion: completion)
                    })
                    
                default:
                    completion(nil , self.userID, error)
                }
                                               
            }
        }
    }
    
    private func demandUserAction(completion: @escaping (_ accessToken: String?, _ userID: String?, _ error : SCWorkerError?) ->()) {
        
        debugPrint("demandUserAction")
        
        self.removeAuthorization()
        
        // delete user Content
        self.userContentWorker?.clearData()
        self.userCityContentWorker?.clearData()
        
        // if we were not able to get access, AND we think we should have been able
        // the we fire a signout message, so that no unautorized access to senisble data
        // is possible
        SCDataUIEvents.postNotification(for: .userDidSignOut)
        
        if reasonForLogout == .invalidRefreshToken {
            completion(nil, nil, .fetchFailed(SCWorkerErrorDetails(message: "Refresh token is invalid")))
        } else {
            completion(nil, nil, nil)
        }
        
        
        // this was too much
        // in the near future, the presentation of an Login VC mus be handled by VC / Presenter Classes
        /*
         // the userActionProvider is injected and is the connection to UI
         self.userActionProvider.demandUserActionLogin() {
         if let accessToken = self.accessToken {
         completion(accessToken)
         } else {
         completion(nil)
         }
         }
         */
    }
    
    // MARK: worker call
    private func requestNewAccessToken(with refreshToken: String,
                                       completion: @escaping (_ accessToken: String?, _ error : SCWorkerError?) ->()) {
        
        SCBackgroundTaskManager.shared.startBackgroundTask(identifier: "backgroundTask.SCAuth.requestNewAccessToken")
        
        self.worker.requestNewAccessToken(with: refreshToken) { (error, authorization) in
            guard error == nil, let authorization = authorization else {
                completion(nil, error)
                SCBackgroundTaskManager.shared.endBackgroundTask(identifier: "backgroundTask.SCAuth.requestNewAccessToken")
                return
            }
            self.set(authorization: authorization,
                     remember: self.shouldRememberLogin)
            
            debugPrint("Successfully got new accessToken")
            SCFileLogger.shared.write("got new accessToken and saved", withTag: .logout)
            completion(authorization.accessToken, nil )
            SCBackgroundTaskManager.shared.endBackgroundTask(identifier: "backgroundTask.SCAuth.requestNewAccessToken")
        }
    }
    
    // MARK: save and/or store the recieved authorization
    private func set(authorization: SCModelAuthorization, remember: Bool) {
        
        self.removeAuthorization() // delete all old auth
        
        self.shouldRememberLogin = remember
        self.accessToken = authorization.accessToken
        self.refreshToken = authorization.refreshToken
        self.accessTokenExpiresIn = authorization.accessTokenExpiresIn
        self.refreshTokenExpiresIn = authorization.refreshTokenExpiresIn
        self.authCreationTime = authorization.birthDate.timeIntervalSinceReferenceDate
        
        storeShouldRememberLoginStatus(status: remember)
        self.storeRefreshToken(token: self.refreshToken)
        storeAccessToken(token: authorization.accessToken)

//        if self.shouldRememberLogin {
//            storeShouldRememberLoginStatus(status: remember)
//            self.storeRefreshToken(token: self.refreshToken)
//        }
        
    }
    
    private func loadToken(for key: String) -> String? {
        #if targetEnvironment(simulator)
        let token = userDefaults.string(forKey: key)
        #else
        let token = keychainHelper.load(key: key)
        #endif
        return token
    }
    
    private func storeAccessToken(token: String?) {
        #if targetEnvironment(simulator)
        userDefaults.set(token, forKey: accessTokenKey)
        #else
        keychainHelper.save(key: accessTokenKey, value: token)
        #endif
    }
    
    private func storeRefreshToken(token: String?) {
        
            
        #if targetEnvironment(simulator)
        userDefaults.set(token, forKey: self.refreshTokenKey)
        #else
        keychainHelper.save(key: refreshTokenKey, value: token)
        #endif
    }
    
    private func loadRefreshToken() -> String? {
        
            
        #if targetEnvironment(simulator)
            
        let token = userDefaults.string(forKey: self.refreshTokenKey)
        
        #else
            
        let token = keychainHelper.load(key: refreshTokenKey)
            
        #endif
            
        return token
            
    }
    
    // MARK: Helper functions
    private func loadShouldRememberLoginStatus() -> Bool {
        
        return userDefaults.bool(forKey: self.shouldRememberLoginKey)
    }
    
    private func storeShouldRememberLoginStatus(status: Bool) {
        
        
        userDefaults.set(status, forKey: self.shouldRememberLoginKey)
    }
    
    private func couldAccessTokenBeValid() -> Bool {
        
        let now = self.convertToTimeInterval(date: Date())
        
        // Adding offset of 5 seconds to the tokenExpiry time in order to avoid any miscalculations on server due to bandwidth or processing time in between
        
        if  ( now + 5 ) < self.authCreationTime + self.accessTokenExpiresIn {
            return true
        } else {
            return false
        }
    }
    
    private func refreshTokenState() -> SCRefreshTokenState {
        SCFileLogger.shared.write("inside refreshTokenState() auth creation time -> \(self.authCreationTime) -> \(String(describing: accessToken))", withTag: .logout)
        self.refreshToken = loadRefreshToken()
        guard self.refreshToken != nil else {
            return .empty
        }
        
        let now = self.convertToTimeInterval(date: Date())
        
        if now < self.authCreationTime + self.refreshTokenExpiresIn {
            return .valid
        } else if refreshTokenExpiresIn == 0 { // Refresh token "expireInKey" is not stored in user defaults.
            return .valid
        } else {
            return .invalid
        }
    }
    
    private func convertToTimeInterval(date: Date) -> TimeInterval{
        return date.timeIntervalSinceReferenceDate
    }
    private func convertToDate(timeInterval: TimeInterval) -> Date {
        return Date(timeIntervalSinceReferenceDate: timeInterval)
    }
}

// MARK: - Public Extensions

// MARK: SCLoginAuthProviding
extension SCAuth: SCLoginAuthProviding {
    public func login(name: String, password: String, remember: Bool,
                      completion: @escaping (SCWorkerError?) -> ()) {
        
        SCRequest.isWaitingForToken = false // TODO: there has to be a better way
        
        let deviceId = "\(UIDevice.current.model)_\(UIDevice.current.systemVersion)"
        // SMARTC-16394 Collect data about logout events
        SCUserDefaultsHelper.setInfoOfLogOutEvent(logOutEventInfo: LogOutEventInfo(userId: SCUserDefaultsHelper.getUserID() ?? "-1", deviceId: deviceId, keepMeLoggedIn: remember))
        
        self.worker.login(name: name, password: password) { (error, authorizationResult) in
            // handle first technical worker errors
            guard error == nil else {
                completion(error)
                SCFileLogger.shared.write("Login Failure | \(error.debugDescription)", withTag: .logout)
                return
            }
            
            if authorizationResult != nil {
                self.set(authorization: authorizationResult!, remember: remember)
                SCFileLogger.shared.write("Login Success | \(authorizationResult!.description())", withTag: .logout)
                SCUserDefaultsHelper.setIsSomeoneEverLoggedIn(status: true)
                completion(nil)
            }
        }
    }
}

// MARK: SCLogoutAuthProviding
extension SCAuth: SCLogoutAuthProviding {
    
    func logout(logoutReason: SCLogoutReason, completion: @escaping ()->()) {
        
        self.reasonForLogout = logoutReason
        
        SCRequest.isWaitingForToken = false
        self.refreshToken = loadRefreshToken()
        guard let refreshToken = self.refreshToken else {
            self.removeAuthorization()
            completion()
            return
        }
        
        self.removeAuthorization()
        
        SCFileLogger.shared.write("Logout | removing Authorization - cleared all authorization details from client", withTag: .logout)
        
        self.worker.logout(refreshToken: refreshToken) { (error, success) in
            debugPrint("Logout successful?", success, "error:", error as Any)
            completion()
        }
        
        // delete user Content
        self.userContentWorker?.clearData()
        self.userCityContentWorker?.clearData()
        
        SCUtilities.delay(withTime: 0.0, callback: {
            SCDataUIEvents.postNotification(for: .didChangeUserInfoItems)
            SCDataUIEvents.postNotification(for: .userDidSignOut)
        })
        
        // SMARTC-16394 Collect data about logout events
        if SCUserDefaultsHelper.getLogOutEvent() {
            let logOutDeviceID = SCUserDefaultsHelper.getInfoOfLogOutEvent()?.deviceId ?? "deviceId"
            
            if let logOutEventInfo = SCUserDefaultsHelper.getInfoOfLogOutEvent() {
                if logOutEventInfo.keepMeLoggedIn && self.reasonForLogout == .technicalReason{

                    // SMARTC-13058 : Track additional events via Adjust - Error cases
                    // User is logged out by accident (ie. this is the case in which we show the popup on QA)
                    UIApplication.shared.adjInjector?.trackEvent(eventName: AnalyticsKeys.EventName.unexpectedLogout)
                    
                    #if !RELEASE && !STABLE
                    SCUtilities.topViewController().showLogoutAlert(logOutDeviceID)
                    #endif
                }
            }
        }
        
    }
}

// MARK: SCAuthTokenProviding
extension SCAuth: SCAuthTokenProviding {
    

    /// this method is trigged after the app launch of if app comes to foreground/ active state from background.
    /// this is trigged before we try to refresh any other contents
    
    public func renewAccessTokenIfValid(completion: @escaping (Bool) -> ()) {
        refreshToken = loadRefreshToken()
        debugPrint("renewAccessTokenIfValid start ")
        SCFileLogger.shared.write("renewAccessTokenIfValid start", withTag: .logout)
        
        /// if user has checked in KMLI then then there is no need to renew the AT as AT will be renewed as a part of the various refresh calls from SCSharedWorkerRefreshHandler that are going to happen after this completion
        
        guard self.shouldRememberLogin == false else {
            debugPrint("self.shouldRememberLogin == true ")
            SCFileLogger.shared.write("self.shouldRememberLogin == true ", withTag: .logout)
            completion(true)
            return
        }
        
        /// if accessToken is not nil  & KMLI == false then the app is still not killed from the last AT retreival, so the session continues
        /// if accessToken is nil & KMLI == false then app was killed and launched again , in this case , we will only refresh the token if the last token is still valid
        if self.accessToken == nil && !couldAccessTokenBeValid() {
            debugPrint("!couldAccessTokenBeValid()")
            SCFileLogger.shared.write("!couldAccessTokenBeValid() -> removeAuthorization()", withTag: .logout)
            
            if let _ = self.refreshToken {
                reasonForLogout = SCLogoutReason.kmliNotChcked
            } else {
                reasonForLogout = SCLogoutReason.wasNotLoggedInBefore
            }
            removeAuthorization()
            completion(false)
            return
        }
        
        // this is a regular check for RT validity
        guard let refreshToken = self.refreshToken else {
            debugPrint("self.refreshToken == nil")
            SCFileLogger.shared.write("self.refreshToken == nil", withTag: .logout)
            completion(false)
            return
        }
        
        if self.refreshTokenState() != .valid{
            debugPrint("self.refreshToken is not valid")
            SCFileLogger.shared.write("self.refreshToken is not valid", withTag: .logout)
            completion(false)
            return
        }
        
        else {
            
            debugPrint("renewAccessTokenIfValid -> requestNewAccessToken")
            SCFileLogger.shared.write("renewAccessTokenIfValid -> requestNewAccessToken", withTag: .logout)
          
            self.requestNewAccessToken(with: refreshToken) { (newAccessToken, error) in
                            
                if error == nil {
                    debugPrint("renewAccessTokenIfValid -> requestNewAccessToken success")
                    SCFileLogger.shared.write("renewAccessTokenIfValid -> requestNewAccessToken success", withTag: .logout)
                    completion(true)
                } else {
                    debugPrint("renewAccessTokenIfValid -> requestNewAccessToken Error \(String(describing: error))")
                    SCFileLogger.shared.write("renewAccessTokenIfValid -> requestNewAccessToken Error \(String(describing: error))", withTag: .logout)
                    completion(false)
                }
            }
        }
    }
    
    
    public func fetchAccessToken(completion: @escaping (_ accessToken: String?, _ userID: String?, _ error : SCWorkerError? ) ->()) {
        
        SCFileLogger.shared.write("Inside SCAuth -> fetchAccessToken", withTag: .logout)
        
        // Inline Documentation
        // the magic steps to get an accessToken
        
        // 1. Do we have an accessToken?
        //  if Yes -> could it be valid?
        //      if YES -> deliver it
        //      if NO -> proceed to 2.
        
        // 2. if NO -> Do we have a refreshToken stored?
        //      IF YES -> could it be valid?
        //          IF YES -> request a new accessToken
        //               IF SUCCESS, deliver it -> COMPLETION
        //                 IF FAILURE, proceed to 3.
        //          IF NO -> proceed to 3.
        //      IF NO:
        //          3. present a login Screen, let user login -> COMPLETION
        
        // ok, let´s do it:
        
        // 1. Do we have an accessToken?
        debugPrint("1. Do we have an accessToken?")
        SCFileLogger.shared.write("1. Do we have an accessToken?", withTag: .logout)
        accessToken = loadToken(for: accessTokenKey)
        guard let accessToken = self.accessToken  else {
            // if NO -> Do we have a refreshToken stored?
            debugPrint("NO -> Do we have a refreshToken stored?")
            SCFileLogger.shared.write("NO -> Do we have a refreshToken stored?", withTag: .logout)
            self.getNewAccessToken(completion: completion)
            return
        }
        
        //  if Yes -> could it be valid?
        debugPrint("Yes -> could it be valid?")
        SCFileLogger.shared.write("Yes -> could it be valid?", withTag: .logout)
        
        if self.couldAccessTokenBeValid() {
            // if YES -> deliver it -> COMPLETION
            debugPrint("YES -> deliver it -> COMPLETION")
            SCFileLogger.shared.write("YES -> deliver it -> COMPLETION", withTag: .logout)
            completion(accessToken, self.userID, nil )
        } else {
            // if NO -> proceed to 1.
            debugPrint("NO -> proceed to 2.")
            SCFileLogger.shared.write("NO -> proceed to 2.", withTag: .logout)
            self.getNewAccessToken(completion: completion)
        }
    }
    
    public func getRefreshToken() -> String? {
        self.refreshToken = loadRefreshToken()
        return self.refreshToken
    }
}

extension SCAuth: SCAuthConfirmationProviding {
    func confirmAuthorization(_for name: String, password: String, completion: @escaping (SCWorkerError?) -> ()) {
        self.worker.login(name: name, password: password) { (error, authorizationResult) in
            // handle first technical worker errors
            guard error == nil else {
                completion(error)
                return
            }
            
            if authorizationResult != nil {
                completion(nil)
            }
        }
    }
    
    
}

extension SCAuth: SCAuthUserIDProviding {
    func set(userID: String) {
        SCUserDefaultsHelper.setUserID(userID)
        self.userID = userID
    }
}
