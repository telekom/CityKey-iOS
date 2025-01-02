//
//  AuthProviding.swift
//  OSCA
//
//  Created by Bhaskar N S on 18/08/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

protocol AuthProviding {
    func fetchAccessToken(completion: @escaping (_ accessToken: String?, _ userID: String?, _ error: NetworkError? ) ->())
    func isUserLoggedIn() -> Bool
    func isUserLoggIn(completionHandler: ((Bool) -> Void)?)
}

class AuthProvider: AuthProviding {
    private var refreshToken: String?
    private var accessToken: String?
    static let shared = AuthProvider()
    private let refreshTokenKey = "RefreshTokenKey"
    private let accessTokenKey = "AccessTokenKey"
    private let accessTokenExpiresInKey = "AccessTokenExpiresInKey"
    private let refreshTokenExpiresInKey = "RefreshTokenExpiresInKey"
    private let authCreationTimeKey = "AuthCreationTimeKey"
    private let shouldRememberLoginKey = "ShouldRememberLoginKey"
    private var userID: String? = SCUserDefaultsHelper.getUserID()
//    private let request: WebServiceUsable
    private let widgetUtility: WidgetUtility
    private var shouldRememberLogin: Bool  = (UserDefaults(suiteName: WidgetUtility().getAppGroupId()) ?? UserDefaults.standard).bool(forKey: "ShouldRememberLoginKey")
    private var keychainHelper: KeychainUsable
    private var userDefaults: UserDefaults {
        return UserDefaults(suiteName: WidgetUtility().getAppGroupId()) ?? UserDefaults.standard
    }
    private var refreshTokenExpiresIn: TimeInterval {
        get {
            return userDefaults.double(forKey: refreshTokenExpiresInKey)
        }
        set {
            userDefaults.set(newValue, forKey: refreshTokenExpiresInKey)
        }
    }
    
    private var accessTokenExpiresIn: TimeInterval {
        get {
            return userDefaults.double(forKey: accessTokenExpiresInKey)
        }
        set {
            userDefaults.set(newValue, forKey: accessTokenExpiresInKey)
        }
    }
    
    private var authCreationTime: TimeInterval {
        get {
            return userDefaults.double(forKey: authCreationTimeKey)
        }
        set {
            userDefaults.set(newValue, forKey: authCreationTimeKey)
        }
    }
    init(widgetUtility: WidgetUtility = WidgetUtility(),
         keychainHelper: KeychainUsable = KeychainHelper()) {
        self.widgetUtility = widgetUtility
        self.keychainHelper = keychainHelper
        self.refreshToken = loadRefreshToken()
    }
    
    func loadToken(for key: String) -> String? {
        #if targetEnvironment(simulator)
        return userDefaults.string(forKey: key)
        #else
        return keychainHelper.load(key: key)
        #endif
    }
    
    private func loadRefreshToken() -> String? {
        
            
        #if targetEnvironment(simulator)
        let token = userDefaults.string(forKey: refreshTokenKey)
        #else
        let token = keychainHelper.load(key: refreshTokenKey)
        #endif
        return token
            
    }
    
    private func loadShouldRememberLoginStatus() -> Bool {
        return userDefaults.bool(forKey: self.shouldRememberLoginKey)
    }
    
    private func storeShouldRememberLoginStatus(status: Bool) {
        userDefaults.set(status, forKey: self.shouldRememberLoginKey)
    }
    
    func fetchAccessToken(completion: @escaping (_ accessToken: String?, _ userID: String?, _ error: NetworkError? ) ->()) {
        SCFileLogger.shared.write("AuthProvider Inside SCAuth -> fetchAccessToken", withTag: .logout)
        self.accessToken = loadToken(for: accessTokenKey)
        // 1. Do we have an accessToken?
        debugPrint("1. Do we have an accessToken?")
        SCFileLogger.shared.write("AuthProvider  1. Do we have an accessToken?", withTag: .logout)
        guard let accessToken = self.accessToken  else {
            // if NO -> Do we have a refreshToken stored?
            debugPrint("NO -> Do we have a refreshToken stored?")
            SCFileLogger.shared.write("AuthProvider NO -> Do we have a refreshToken stored?", withTag: .logout)
            self.getNewAccessToken(completion: completion)
            return
        }
        //  if Yes -> could it be valid?
        debugPrint("Yes -> could it be valid?")
        
        if self.couldAccessTokenBeValid() {
            // if YES -> deliver it -> COMPLETION
            debugPrint("YES -> deliver it -> COMPLETION")
            completion(accessToken, userID, nil )
        } else {
            // if NO -> proceed to 1.
            debugPrint("NO -> proceed to 2.")
            self.getNewAccessToken(completion: completion)
        }
    }
    
    // MARK: the get token logic
    public func getNewAccessToken(completion: @escaping (_ accessToken: String? , _ userID: String?, _ error : NetworkError?) ->()) {
        // 2. Do we have a refreshToken stored?
        debugPrint("2. Do we have a refreshToken stored?")
        SCFileLogger.shared.write("AuthProvider 2. Do we have a refreshToken stored?", withTag: .logout)
        self.refreshToken = loadRefreshToken()
        guard let refreshToken = self.refreshToken else {
            // IF NO
            // 3. present a login Screen
            debugPrint("NO present a login Screen")
            //TODO: notify user to login again in the app
            SCFileLogger.shared.write("AuthProvider  NO present a login Screen", withTag: .logout)
            return
        }
        // IF YES -> could it be valid?
        debugPrint("YES -> could it be valid?")
        SCFileLogger.shared.write("AuthProvider YES -> could it be valid?", withTag: .logout)
        if self.refreshTokenState() == .invalid {
            // IF NO -> proceed with 3.
            //TODO: notify user to login again in the app
            debugPrint("NO -> proceed with 3.")
            SCFileLogger.shared.write("AuthProvider NO -> proceed with 3.", withTag: .logout)
            return
        }
        
        // IF YES -> request a new accessToken
        debugPrint("YES -> request a new accessToken")
        SCFileLogger.shared.write("AuthProvider YES -> request a new accessToken", withTag: .logout)
        self.requestNewAccessToken(with: refreshToken) { (authorization, error) in
            
            if let authorization = authorization {
                // IF SUCCESS, deliver it -> COMPLETION
                SCFileLogger.shared.write("AuthProvider IF SUCCESS, deliver it -> COMPLETION", withTag: .logout)
                debugPrint("AuthProvider IF SUCCESS, deliver it -> COMPLETION")
                self.set(authorization: authorization, remember: self.shouldRememberLogin)
                completion(authorization.accessToken, self.userID, nil)
            } else if let error = error  {
                SCFileLogger.shared.write("AuthProvider AuthProvider IF FAILURE, proceed to 3. \(error)", withTag: .logout)
                completion(nil , self.userID, error)
            }
        }
    }
    
    // MARK: worker call
    private func requestNewAccessToken(with refreshToken: String,
                                            completion: @escaping (_ authorization: SCModelAuthorization?,
                                                                   NetworkError?) -> ()) {
        
        // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
//        SCUserDefaultsHelper.setLogOutEvent(true)
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif
        let apiPath = "/api/v2/smartcity/userManagement?cityId=\(cityID)&actionName=POST_RefreshToken"
        
        guard let url = URL(string: widgetUtility.baseUrl(apiPath: apiPath)) else {
            return
        }
        
        let requestBody = try! JSONEncoder().encode(["refreshToken" : refreshToken])
        WebServiceRequest.shared.fetchData(from: url, method: "POST", body: requestBody, needsAuth: false) { (result) in
            switch result {
            case .success(let fetchedData):
                guard let fetchedData = fetchedData else {
                    return
                }
                do {
                    let httpModel = try JSONDecoder().decode(SCHttpModelResponse<SCHttpModelAuthorization>.self, from: fetchedData)
                    SCFileLogger.shared.write("AuthProvider Request New Access Token Call - Success | model : \(httpModel.content.toModel().description())", withTag: .logout)
                    completion(httpModel.content.toModel(), nil)
                } catch {
                    SCFileLogger.shared.write("AuthProvider Request New Access Token Call - Failure | Exception parsing JSON response ", withTag: .logout)
                    completion(nil, NetworkError.systemError("Technical error"))
                }
            case .failure(let error):
                SCFileLogger.shared.write("AuthProvider Request New Access Token Call - Failure | \(error) ", withTag: .logout)
                completion(nil, NetworkError.apiError(error.localizedDescription))
            }
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
        storeToken(key: accessTokenKey, token: authorization.accessToken)
//        if self.shouldRememberLogin {
//            storeShouldRememberLoginStatus(status: remember)
//            self.storeRefreshToken(token: self.refreshToken)
//        }
        
    }
    
    private func storeToken(key: String, token: String?) {
        #if targetEnvironment(simulator)
        userDefaults.set(token, forKey: key)
        #else
        keychainHelper.save(key: accessTokenKey, value: token)
        #endif
    }
    
    private func storeRefreshToken(token: String?) {
        #if targetEnvironment(simulator)
        userDefaults.set(token, forKey: refreshTokenKey)
        #else
        keychainHelper.save(key: refreshTokenKey, value: token)
        #endif
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
        self.storeRefreshToken(token: nil)
        self.storeShouldRememberLoginStatus(status: false)
        keychainHelper.clear()
    }
    
    private func couldAccessTokenBeValid() -> Bool {
        
        let now = convertToTimeInterval(date: Date())
        
        // Adding offset of 5 seconds to the tokenExpiry time in order to avoid any miscalculations on server due to bandwidth or processing time in between
        
        if  ( now + 5 ) < self.authCreationTime + self.accessTokenExpiresIn {
            return true
        } else {
            return false
        }
    }
    
    private func convertToTimeInterval(date: Date) -> TimeInterval{
        return date.timeIntervalSinceReferenceDate
    }
    
    private func refreshTokenState() -> SCRefreshTokenState {
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
    
    func isUserLoggedIn() -> Bool {
        self.accessToken = loadToken(for: "AccessTokenKey")
        /// if we still have accessToken that means the app was not killed since we retrieved the token , so the session is still valid
        if self.accessToken != nil && couldAccessTokenBeValid() {
            SCFileLogger.shared.write("AuthProvider isUserLoggedIn() access token is not nil", withTag: .logout)
            return true
        }
        
        /// If shouldRememberLogin is false then user is logged in only if the last AT is still valid
        if self.shouldRememberLogin == false {
            SCFileLogger.shared.write("AuthProvider isUserLoggedIn() should remember login = false", withTag: .logout)
            if !couldAccessTokenBeValid() {
                SCFileLogger.shared.write("AuthProvider access token is not valid -> \(String(describing: accessToken))", withTag: .logout)
                return false
            }
        }

        /// if shouldRememberLogin is true then user is logged in only if the RT is valid ( RT is valid for 90 Days )
        let tokenState = self.refreshTokenState()
        SCFileLogger.shared.write("AuthProvider Refresh token state is \(tokenState)", withTag: .logout)
        switch tokenState {
        case .valid:
            return true
        case .empty, .invalid:
            return false
        }
    }

    func isUserLoggIn(completionHandler: ((Bool) -> Void)?) {
        self.accessToken = loadToken(for: "AccessTokenKey")
        /// if we still have accessToken that means the app was not killed since we retrieved the token , so the session is still valid
        if self.accessToken != nil && couldAccessTokenBeValid() {
            SCFileLogger.shared.write("AuthProvider isUserLoggedIn() access token is not nil", withTag: .logout)
            completionHandler?(true)
            return
        }
        
        /// If shouldRememberLogin is false then user is logged in only if the last AT is still valid
        if self.shouldRememberLogin == false {
            SCFileLogger.shared.write("AuthProvider isUserLoggedIn() should remember login = false", withTag: .logout)
            if !couldAccessTokenBeValid() {
                SCFileLogger.shared.write("AuthProvider access token is not valid -> \(String(describing: accessToken))", withTag: .logout)
                fetchAccessToken { accessToken, userID, error in
                    guard error == nil else {
                        completionHandler?(false)
                        return
                    }
                    completionHandler?(true)
                }
            }
        }
        
        /// if shouldRememberLogin is true then user is logged in only if the RT is valid ( RT is valid for 90 Days )
        let tokenState = self.refreshTokenState()
        SCFileLogger.shared.write("AuthProvider Refresh token state is \(tokenState)", withTag: .logout)
        switch tokenState {
        case .valid:
            fetchAccessToken { accessToken, userID, error in
                guard error == nil else {
                    completionHandler?(false)
                    return
                }
                completionHandler?(true)
            }
        case .empty,
                .invalid:
            completionHandler?(false)
        }
    }
}
