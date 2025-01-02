//
//  SCDataRequest.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 03.04.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import UIKit

enum SCRequestResult {
    case success(Data)
    case failure(SCRequestError)
    
    static func from(error : SCWorkerError) -> Self {
        
        switch error {
        
        case .noInternet:
            return .failure(.noInternet)
            
        case .technicalError:
            return .failure(.unexpected(SCRequestErrorDetails.unexpectedError(clientTrace: "Technical error", appendErrorCodeInMsg: .error107)))
            
        case .unauthorized:
            return .failure(.unauthorized(SCRequestErrorDetails.notAuthorized(clientTrace: "Unauthorized")))
            
        case .fetchFailed(let workerErrorDetails):
            
            if let errorCode = workerErrorDetails.errorCode {
                
                return .failure(SCRequestError.requestFailed( SCHTTPCode(errorCode) ?? 0, SCRequestErrorDetails(errorCode: errorCode, userMsg: workerErrorDetails.message, errorClientTrace: "fetch Failed")))
            } else {
                return .failure(SCRequestError.requestFailed(0, SCRequestErrorDetails(errorCode: "0", userMsg: workerErrorDetails.message, errorClientTrace: "fetch failed with no error code")))
            }
            
        }
    }
}

struct SCQueuedAuthRequest {
    var request: URLRequest
    let completion: SCRequestCompletionBlock
}

enum SCRequestError: Error {
    // Response contains no data, couldn't be parsed...
    case invalidResponse(SCHTTPCode, SCRequestErrorDetails)
    // Request was executed but we got an error from the backend
    case requestFailed(SCHTTPCode, SCRequestErrorDetails)
    // noInternet
    case noInternet
    // behindhotspot
    // User isn't authorized anymore
    case unauthorized(SCRequestErrorDetails)
    // Request timed out
    case timeout(SCRequestErrorDetails)
    // all other unexpected errors
    case unexpected(SCRequestErrorDetails)
}

enum UnfortunatelyError: String {

    case error101 = "101" // Request Timed out
    case error102 = "102" // Network connection lost
    case error103 = "103" // Unknown http code
    case error104 = "104" // Data is nil
    case error105 = "105" // Request could not be parsed
    case error106 = "106" // HTTP StatusCode(>=300)
    case error107 = "107" // Technical error
    case error108 = "108" // Default
    case error109 = "109" // Other Internet Issue

    func fullErrorString() -> String {
        return "z_001_error".localized() + " " + self.rawValue
    }
}

struct SCRequestErrorDetails: Error {
    let errorCode: String
    let userMsg: String
    let errorClientTrace: String
    
    static func invalidResponse(clientTrace : String, appendErrorCodeInMsg: UnfortunatelyError = .error108) -> SCRequestErrorDetails {
        return SCRequestErrorDetails(errorCode: "INT000000", userMsg: "dialog_technical_error_message".localized() + " (\(appendErrorCodeInMsg.fullErrorString()))", errorClientTrace: clientTrace)
    }
    
    static func unexpectedError(clientTrace : String, appendErrorCodeInMsg: UnfortunatelyError = .error108) -> SCRequestErrorDetails {
        return SCRequestErrorDetails(errorCode: "INT0000001", userMsg: "dialog_technical_error_message".localized() + " (\(appendErrorCodeInMsg.fullErrorString()))", errorClientTrace: clientTrace)
    }
    
    static func timeout(clientTrace : String, appendErrorCodeInMsg: UnfortunatelyError = .error108) -> SCRequestErrorDetails {
        return SCRequestErrorDetails(errorCode: "INT0000002", userMsg: "dialog_technical_error_message".localized() + " (\(appendErrorCodeInMsg.fullErrorString()))" , errorClientTrace: clientTrace)
    }
    static func notAuthorized(clientTrace : String, appendErrorCodeInMsg: UnfortunatelyError = .error108) -> SCRequestErrorDetails {
        return SCRequestErrorDetails(errorCode: "INT0000003", userMsg: "dialog_technical_error_message".localized() + " (\(appendErrorCodeInMsg.fullErrorString()))", errorClientTrace: clientTrace)
    }
}

protocol SCDataFetching: AnyObject {
    
    func fetchData(from url: URL,
                   method: String,
                   body: Data?,
                   needsAuth: Bool,
                   completion:@escaping ((SCRequestResult) -> ()))
    
    func uploadData(from url: URL,
                    method: String,
                    body: Data?,
                    needsAuth: Bool,
                    additionalHeaders: [String: String],
                    completion:@escaping ((SCRequestResult) -> ()))
    
    func cancel()
}

protocol SCRequestCreating {
    func createRequest() -> SCDataFetching
}

typealias SCRequestCompletionBlock = ((SCRequestResult) -> ())

class SCRequest: SCDataFetching, SCRequestCreating {
    
    static var isWaitingForToken: Bool = false
    private static var authRequestQueue = [SCQueuedAuthRequest]()
    private var task: URLSessionDataTask?
    private let lockForWaitingForAccessTokenFlag = NSLock()
    private var accessTokenBackgroundTaskIdentifier : UIBackgroundTaskIdentifier = .invalid
    var networkConnectionLostRetryCounter = 2
    var requestTimeOutRetryCounter = 7
    
    func createRequest() -> SCDataFetching {
        return SCRequest()
    }
    
    func fetchData(from url: URL,
                   method: String,
                   body: Data?,
                   needsAuth: Bool,
                   completion: @escaping SCRequestCompletionBlock)
    {
        print("--*--SCRequest")
        print("--*--",url.absoluteString)
        guard !isBaseUrlMockCityKey(for: url) else {
            if let actionName = extractActionName(from: url),
               let fetchedData = fetchLocalJson(with: actionName) {
                completion(.success(fetchedData))
                return
            } else {
                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "Network connection lost", appendErrorCodeInMsg: .error102))))
            }
            return
        }

        var request = URLRequest(url: url)
        SCFileLogger.shared.write("inside fetchData for request URL : \(url) ", withTag: .logout)
        
        request.httpMethod = method
        request.httpBody = body
        
        // Header Configuration
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(SCUtilities.preferredContentLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("CITYKEY", forHTTPHeaderField: "Requesting-App")
        request.addValue(SCUserDefaultsHelper.getUserID() ?? "-1", forHTTPHeaderField: "User-Id")
        request.addValue(!isPreviewMode ? "LIVE" : "PREVIEW", forHTTPHeaderField: "Mode")

        if let pushToken =  SCDeviceUniqueID.shared.getDeviceUniqueID() {
            request.addValue(pushToken, forHTTPHeaderField: "Push-Id")
        }
        
        // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
        if SCUserDefaultsHelper.getLogOutEvent() {
            if let logOutEventInfo = SCUserDefaultsHelper.getInfoOfLogOutEvent() {
                request.addValue(logOutEventInfo.deviceId, forHTTPHeaderField: "Device-Id")
                request.addValue(String(logOutEventInfo.keepMeLoggedIn), forHTTPHeaderField: "Keep-Me-LoggedIn")
            }
        }
        
        request = SCVersionHelper.addVersionHeadersTo(request)
        
        guard needsAuth else {
            self.send(request, needsAuth: needsAuth, completion: completion)
            return
        }
        
        let queuedRequest = SCQueuedAuthRequest(request: request,
                                                completion: completion)
        
        SCFileLogger.shared.write("lockForWaitingForAccessTokenFlag.lock()", withTag: .logout)
        lockForWaitingForAccessTokenFlag.lock()
        if SCRequest.isWaitingForToken {
            SCFileLogger.shared.write("isWaitingForToken = true -> adding request to queue : \(queuedRequest) ", withTag: .logout)
            lockForWaitingForAccessTokenFlag.unlock()
            SCFileLogger.shared.write("lockForWaitingForAccessTokenFlag.unlock()", withTag: .logout)
            SCRequest.authRequestQueue.append(queuedRequest)
        } else {
            SCRequest.isWaitingForToken = true
            lockForWaitingForAccessTokenFlag.unlock()
            SCFileLogger.shared.write("lockForWaitingForAccessTokenFlag.unlock()", withTag: .logout)
            SCFileLogger.shared.write("inside fireAuthRequest for request : \(request.debugDescription)", withTag: .logout)
            self.fireAuthRequest(queuedRequest)
        }
    }
    
    func uploadData(from url: URL,
                    method: String,
                    body: Data?,
                    needsAuth: Bool,
                    additionalHeaders: [String: String],
                    completion: @escaping SCRequestCompletionBlock)
    {
        guard !isBaseUrlMockCityKey(for: url) else {
            if let actionName = extractActionName(from: url),
               let fetchedData = fetchLocalJson(with: actionName) {
                completion(.success(fetchedData))
                return
            } else {
                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "Network connection lost", appendErrorCodeInMsg: .error102))))
            }
            return
        }
        
        var request = URLRequest(url: url)
        SCFileLogger.shared.write("inside fetchData for request URL : \(url) ", withTag: .logout)
        
        request.httpMethod = method
        request.httpBody = body
        
        // Header Configuration
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(SCUtilities.preferredContentLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("CITYKEY", forHTTPHeaderField: "Requesting-App")
        request.addValue(SCUserDefaultsHelper.getUserID() ?? "-1", forHTTPHeaderField: "User-Id")
        request.addValue(!isPreviewMode ? "LIVE" : "PREVIEW", forHTTPHeaderField: "Mode")

        if let pushToken = SCNotificationManager.shared.pushToken  {
            request.addValue(pushToken, forHTTPHeaderField: "Push-Id")
        }
        
        // SMARTC-16772 iOS: Implement Dialog when user Unexpectedly logouts
        if SCUserDefaultsHelper.getLogOutEvent() {
            if let logOutEventInfo = SCUserDefaultsHelper.getInfoOfLogOutEvent() {
                request.addValue(logOutEventInfo.deviceId, forHTTPHeaderField: "Device-Id")
                request.addValue(String(logOutEventInfo.keepMeLoggedIn), forHTTPHeaderField: "Keep-Me-LoggedIn")
            }
        }
        
        request = SCVersionHelper.addVersionHeadersTo(request)
        
        for header in additionalHeaders{
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        guard needsAuth else {
            self.send(request, needsAuth: needsAuth, completion: completion)
            return
        }
        
        let queuedRequest = SCQueuedAuthRequest(request: request,
                                                completion: completion)
        
        if SCRequest.isWaitingForToken {
            SCFileLogger.shared.write("isWaitingForToken = true -> adding request to queue : \(queuedRequest) ", withTag: .logout)
            SCRequest.authRequestQueue.append(queuedRequest)
        } else {
            SCRequest.isWaitingForToken = true
            
            SCFileLogger.shared.write("inside fireAuthRequest for request : \(request.debugDescription)", withTag: .logout)
            self.fireAuthRequest(queuedRequest)
        }
    }
    
    func cancel(){
        self.task?.cancel()
    }
    
    private func fireAuthRequest(_ queuedRequest: SCQueuedAuthRequest) {
        
        //startBackgroundTask()
        SCBackgroundTaskManager.shared.startBackgroundTask(identifier: "backgroundTask.fireAuthRequest.requestNewAccessToken")
        
        SCAuth.shared.fetchAccessToken { (accessToken, userID, error) in
            SCRequest.isWaitingForToken = false
            
            //self.endBackgroundTask()
            SCBackgroundTaskManager.shared.endBackgroundTask(identifier: "backgroundTask.fireAuthRequest.requestNewAccessToken")
            
            guard let token = accessToken else {
                
                //queuedRequest.completion(.failure(SCRequestError.unauthorized(SCRequestErrorDetails.notAuthorized(clientTrace: "Request cancelled"))))
                if let error = error {
                    queuedRequest.completion(SCRequestResult.from(error: error))
                } else {
                    queuedRequest.completion(SCRequestResult.failure(SCRequestError.unexpected(SCRequestErrorDetails(errorCode: "0", userMsg: "AccesToken retrival failed", errorClientTrace: ""))))
                }
                self.removeAllQueuedRequest()
                return
            }
            
            var urlRequest = queuedRequest.request
            urlRequest.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
            SCFileLogger.shared.write("inside fireAuthRequest Bearer Token : \(token) for \(String(describing: urlRequest.url?.debugDescription))", withTag: .logout)
            
            //            if userID != nil && userID!.count > 0 {
            //                urlRequest.addValue(userID!, forHTTPHeaderField: "User-Id")
            //            }
            self.send(urlRequest, needsAuth: true, completion: { (result) in
                queuedRequest.completion(result)
                SCFileLogger.shared.write("inside fireAuthRequest send competion for \(urlRequest.debugDescription)", withTag: .logout)
                if !SCRequest.isWaitingForToken {  self.triggerNextQueuedRequest() }
            })
        }
    }
    
    private func triggerNextQueuedRequest() {
        
        SCFileLogger.shared.write("inside triggerNextQueuedRequest authRequestQueue count:\(SCRequest.authRequestQueue.count)", withTag: .logout)
        
        guard SCRequest.authRequestQueue.count > 0 else {
            return
        }
        
        let nextRequest = SCRequest.authRequestQueue.removeLast()
        SCFileLogger.shared.write("inside triggerNextQueuedRequest triggering request \(nextRequest.request.debugDescription)", withTag: .logout)
        self.fireAuthRequest(nextRequest)
        //self.triggerNextQueuedRequest()
    }
    
    private func removeAllQueuedRequest() {
        SCRequest.authRequestQueue.removeAll()
    }
    
    private func send(_ request: URLRequest, needsAuth: Bool,
                      completion:@escaping SCRequestCompletionBlock) {
        // Ephemeral configuration is used to stop caching sensitive information
        SCFileLogger.shared.write("SCRequest -> send ( AppState = \(SCUtilities.applicationState()))", withTag: .logout)
        // Set timeout for request to 30 seconds
        let confing = URLSessionConfiguration.ephemeral
        confing.timeoutIntervalForRequest = 30
        self.task = URLSession(configuration: confing).dataTask(with: request) { [weak self] (data, response, error) in
            
            DispatchQueue.main.async {
                
                guard error == nil else {
                    // TODO : Handle TIMEOUTS as a seperate error type
                    
                    let status = SCReachability().connectionStatus()
                    
                    switch status {
                    case .unknown, .offline:
                        print("Not connected")
                        SCFileLogger.shared.write("SCRequest -> send -> URLSession error -> SCRequestError.noInternet", withTag: .logout)
                        completion(.failure(SCRequestError.noInternet))
                        break
                    case .online(.wwan),.online(.wiFi):
                        print("Connected via WiFi OR WWAN")
                        SCFileLogger.shared.write("SCRequest -> send -> URLSession error -> Connected via WiFi OR WWAN", withTag: .logout)
                        switch (error as? URLError)?.code {
                        case .some(.timedOut):
                            // Handle session timeout
                            print("Request timed out")
                            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                                if delegate.appIsInBackground && self?.requestTimeOutRetryCounter != 0 {
                                    SCFileLogger.shared.write("Request timed out retryng request: \(String(describing: request.url))", withTag: .logout)
                                    self?.requestTimeOutRetryCounter -= 1
                                    self?.send(request, needsAuth: needsAuth, completion: completion)
                                } else {
                                    SCFileLogger.shared.write("Request timed out completion handler: \(request.url)", withTag: .logout)
                                    completion(.failure(SCRequestError.timeout(SCRequestErrorDetails.timeout(clientTrace: "Request Timed Out", appendErrorCodeInMsg: .error101))))
                                }
                            } else {
                                completion(.failure(SCRequestError.timeout(SCRequestErrorDetails.timeout(clientTrace: "Request Timed Out", appendErrorCodeInMsg: .error101))))
                            }
                        case .some(.networkConnectionLost):
                            if self?.networkConnectionLostRetryCounter == 0 {
                                print("Connection cant be established")
                                SCFileLogger.shared.write("Network connection lost completion handler: \(String(describing: request.url))", withTag: .logout)
                                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "Network connection lost", appendErrorCodeInMsg: .error102))))
                                break
                            }
                            SCFileLogger.shared.write("Network connection lost retrying request: \(String(describing: request.url))", withTag: .logout)
                            self?.networkConnectionLostRetryCounter -= 1
                            self?.send(request, needsAuth: needsAuth, completion: completion)
                        default:
                            print("other internet issues")
                            if self?.requestTimeOutRetryCounter == 0 {
                                print("Network issue persists")
                                SCFileLogger.shared.write("other internet issues completion handler: \(String(describing: request.url))", withTag: .logout)
                                completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "The Request Timed Out", appendErrorCodeInMsg: .error109))))
                                break
                            }
                            SCFileLogger.shared.write("other internet issues retryning request: \(String(describing: request.url))", withTag: .logout)
                            self?.requestTimeOutRetryCounter -= 1
                            self?.send(request, needsAuth: needsAuth, completion: completion)
                        }
                        break
                    }
                    return
                }
                
                guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "Unknown http code", appendErrorCodeInMsg: .error103))))
                    return
                }
                
                guard let fetchedData = data else {
                    debugPrint("SCRequest: data is nil", httpStatusCode)
                    SCFileLogger.shared.write("SCRequest: data is nil", withTag: .logout)
                    completion(.failure(SCRequestError.invalidResponse(httpStatusCode, SCRequestErrorDetails.invalidResponse(clientTrace: "Data is nil", appendErrorCodeInMsg: .error104))))
                    return
                }
                //let test = String(decoding: fetchedData, as: UTF8.self)
                
                if fetchedData.isEmpty && SCRequest.isStatusCodeTwoXx(httpStatusCode) {
                    SCFileLogger.shared.write("! fetchedData.isEmpty && SCRequest.isStatusCodeTwoXx(httpStatusCode) ", withTag: .logout)
                    completion(.success(fetchedData))
                    return
                }
                
                // 401 Unauthorized
                guard httpStatusCode != 401, httpStatusCode != 400, httpStatusCode != 403  else {
                    
                    debugPrint("SCRequest NOT AUTHORIZED: httpStatusCode", httpStatusCode)
                    SCFileLogger.shared.write("SCRequest -> send \(request.debugDescription) NOT AUTHORIZED: httpStatusCode = \(httpStatusCode)", withTag: .logout)
                    
                    var authError = SCRequestError.unauthorized(SCRequestErrorDetails.notAuthorized(clientTrace: "Unauthorized Request could not be parsed", appendErrorCodeInMsg: .error105))
                    
                    do {
                        
                        let baseModel = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                        
                        // return error when an error object in the response exists
                        if let errorInfo = baseModel.errors?.first {
                            let requestErrorDetails = SCRequestErrorDetails(errorCode: errorInfo.errorCode, userMsg: errorInfo.userMsg, errorClientTrace: "no trace")
                            authError  = SCRequestError.unauthorized( requestErrorDetails)
                        }
                        
                    } catch {
                        SCFileLogger.shared.write("SCRequest-> send : baseParsingFailed \(httpStatusCode)", withTag: .logout)
                        debugPrint("SCRequest: baseParsingFailed \(httpStatusCode)")
                    }
                    
                    if needsAuth == false {
                        SCFileLogger.shared.write("SCRequest -> send : needsAuth == false returning with authFailure ( unathorised ) \(httpStatusCode)", withTag: .logout)
                        completion(.failure(authError))
                        return
                    }
                    
                    SCAuth.shared.getNewAccessToken(completion: { (accessToken, userID, error) in
                        
                        guard accessToken != nil else {
                            
                            SCFileLogger.shared.write(" send -> SCAuth.shared.getNewAccessToken failed with error \(error.debugDescription) ", withTag: .logout)
                            debugPrint("SCRequest: Unauthorized\(httpStatusCode)")
                            completion(.failure(authError))
                            return
                        }
                        
                        // restart that request again
                        guard let url = request.url,
                              let method = request.httpMethod else {
                            debugPrint("Unauthorized Request could not be restarted")
                            completion(.failure(SCRequestError.unexpected(SCRequestErrorDetails.invalidResponse(clientTrace: "Unauthorized Request could not be restarted"))))
                            return
                        }
                        self?.fetchData(from: url,
                                       method: method,
                                       body: request.httpBody,
                                       needsAuth: needsAuth,
                                       completion: completion)
                    })
                    return
                }
                
                
                do {
                    //let test = String(decoding: fetchedData, as: UTF8.self)
                    
                    let baseModel = try JSONDecoder().decode(SCHttpModelBaseResponse.self, from: fetchedData)
                    
                    // return all errors when an error object in the response exists
                    if let errorInfos = baseModel.errors {
                        if errorInfos.count == 0 {
                            SCFileLogger.shared.write("SCRequest -> send :  errorInfos.count == 0 ", withTag: .logout)
                            completion(.failure(SCRequestError.invalidResponse(httpStatusCode, SCRequestErrorDetails.invalidResponse(clientTrace: SCRequest.traceOfFailedData(fetchedData), appendErrorCodeInMsg: .error105))))
                            return
                        }
                        for errorInfo in errorInfos{
                            SCFileLogger.shared.write("SCRequest -> send :  errorInfos > 0 -> \(errorInfo) ", withTag: .logout)
                            let requestErrorDetails = SCRequestErrorDetails(errorCode: errorInfo.errorCode, userMsg: errorInfo.userMsg, errorClientTrace: "no trace")
                            completion(.failure(SCRequestError.requestFailed(httpStatusCode, requestErrorDetails)))
                        }
                    } else {
                        if httpStatusCode >= 300 {
                            SCFileLogger.shared.write("SCRequest -> send :  httpStatusCode >= 300 (\(httpStatusCode) ", withTag: .logout)
                            completion(.failure(SCRequestError.invalidResponse(httpStatusCode, SCRequestErrorDetails.invalidResponse(clientTrace: "HTTP StatusCode(>=300)", appendErrorCodeInMsg: .error106))))
                        } else {
                            //let test = String(decoding: fetchedData, as: UTF8.self)
                            SCFileLogger.shared.write("SCRequest -> send :  completion(.success(fetchedData)) ", withTag: .logout)
                            completion(.success(fetchedData))
                        }
                    }
                    
                } catch {
                    debugPrint("SCRequest: baseParsingFailed \(httpStatusCode)")
                    SCFileLogger.shared.write("SCRequest -> send :  catch ( line 428 ) ", withTag: .logout)
                    completion(.failure(SCRequestError.invalidResponse(httpStatusCode, SCRequestErrorDetails.invalidResponse(clientTrace: SCRequest.traceOfFailedData(fetchedData), appendErrorCodeInMsg: .error105))))
                }
            }
        }
        
        self.task?.resume()
    }
    
    
    static func traceOfFailedData(_ failedData: Data) -> String{
        if let dictJSON = (try? JSONSerialization.jsonObject(with: failedData, options: [])) as? [String: Any] {
            return dictJSON.debugDescription
        } else {
            return "Serialization failed!"
        }
    }
    
    static func isStatusCodeTwoXx(_ httpStatusCode: Int) -> Bool {
        return 200 <= httpStatusCode && httpStatusCode <= 202
    }
    
    func isBaseUrlMockCityKey(for url: URL) -> Bool {
        return url.host == "mock.api.citykey"
    }
    
    func extractActionName(from url: URL) -> String? {
        guard let components = URLComponents(url: url,
                                             resolvingAgainstBaseURL: false) else {
            return nil
        }
        for queryItem in components.queryItems ?? [] {
            if queryItem.name == "actionName" {
                return queryItem.value
            }
        }
        return nil
    }
    
    private func fetchLocalJson(with fileName: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fetchedData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return fetchedData
              } catch {
                  return nil
              }
        }
        return nil
    }

    
    
//    func startBackgroundTask() {
//
//        SCFileLogger.shared.write("backgroundTask.requestNewAccessToken -> created", withTag: .logout)
//        accessTokenBackgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "backgroundTask.requestNewAccessToken", expirationHandler: { [weak self] in
//
//            SCFileLogger.shared.write("backgroundTask.requestNewAccessToken -> ended by system", withTag: .logout)
//            if let selff = self {
//                UIApplication.shared.endBackgroundTask(selff.accessTokenBackgroundTaskIdentifier)
//                selff.accessTokenBackgroundTaskIdentifier = .invalid
//            }
//        })
//    }
//
//    func endBackgroundTask() {
//
//        if self.accessTokenBackgroundTaskIdentifier != .invalid {
//
//            SCFileLogger.shared.write("backgroundTask.requestNewAccessToken -> ended due to success", withTag: .logout)
//            UIApplication.shared.endBackgroundTask(accessTokenBackgroundTaskIdentifier)
//            self.accessTokenBackgroundTaskIdentifier = .invalid
//        }
//    }
    
}
