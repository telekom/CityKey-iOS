//
//  WebServiceRequest.swift
//  WasteCalendar
//
//  Created by Bhaskar N S on 11/08/22.
//

import Foundation

class WebServiceRequest: WebServiceUsable {
    
    static var isWaitingForToken: Bool = false
    private var task: URLSessionDataTask?
    private static var authRequestQueue = [QueuedAuthRequest]()
    private let lockForWaitingForAccessTokenFlag = NSLock()
    static let shared = WebServiceRequest()
    var requestTimeOutRetryCounter = 3
    private init() { }
    
    func fetchData(from url: URL,
                   method: String,
                   body: Data?,
                   needsAuth: Bool,
                   completion: @escaping (Result<Data?, NetworkError>) -> Void) {
        guard !isBaseUrlMockCityKey(for: url) else {
            if let actionName = extractActionName(from: url),
               let fetchedData = fetchLocalJson(with: actionName) {
                completion(.success(fetchedData))
                return
            } else {
                completion(.failure(NetworkError.systemError("")))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(WidgetUtility().getPrefferedLanguage(), forHTTPHeaderField: "Accept-Language")
        request.addValue("CITYKEY", forHTTPHeaderField: "Requesting-App")
        request.addValue("iOS", forHTTPHeaderField: "OS-Name")
        request.addValue(GlobalConstants.kSupportedServiceAPIVersion, forHTTPHeaderField: "App-Version")
        request.addValue(SCUserDefaultsHelper.getUserID() ?? "-1", forHTTPHeaderField: "User-Id")
        
        if SCUserDefaultsHelper.getLogOutEvent() {
            if let logOutEventInfo = SCUserDefaultsHelper.getInfoOfLogOutEvent() {
                request.addValue(logOutEventInfo.deviceId, forHTTPHeaderField: "Device-Id")
                request.addValue(String(logOutEventInfo.keepMeLoggedIn), forHTTPHeaderField: "Keep-Me-LoggedIn")
            }
        }
        
        if let pushToken =  SCDeviceUniqueID.shared.getDeviceUniqueID() {
            request.addValue(pushToken, forHTTPHeaderField: "Push-Id")
        }
        guard needsAuth else {
            send(request: request, needsAuth: needsAuth, completion: completion)
            return
        }
        let queuedRequest = QueuedAuthRequest(request: request,
                                                completion: completion)
        lockForWaitingForAccessTokenFlag.lock()
        if WebServiceRequest.isWaitingForToken {
            lockForWaitingForAccessTokenFlag.unlock()
            WebServiceRequest.authRequestQueue.append(queuedRequest)
        } else {
            WebServiceRequest.isWaitingForToken = true
            lockForWaitingForAccessTokenFlag.unlock()
            fireAuthRequest(queuedRequest)
        }
    }
    
    private func fireAuthRequest(_ queuedRequest: QueuedAuthRequest) {
        AuthProvider.shared.fetchAccessToken { [weak self] accessToken, userID, error in
            WebServiceRequest.isWaitingForToken = false
            guard let strongSelf = self else {
                return
            }
            guard let accessToken = accessToken else {
                if let error = error {
                    queuedRequest.completion(.failure(NetworkError.apiError(error.localizedDescription)))
                } else {
                    queuedRequest.completion(.failure(NetworkError.apiError("Failed of perfom network request")))
                }
                strongSelf.removeAllQueuedRequest()
                return
            }
            var request = queuedRequest.request
            request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            strongSelf.send(request: request, needsAuth: true) { result in
                queuedRequest.completion(result)
                if !WebServiceRequest.isWaitingForToken {
                    strongSelf.triggerNextQueuedRequest()
                }
            }
        }
    }
    
    private func triggerNextQueuedRequest() {
        guard WebServiceRequest.authRequestQueue.count > 0 else {
            return
        }
        let nextRequest = WebServiceRequest.authRequestQueue.removeLast()
        self.fireAuthRequest(nextRequest)
    }
    
    private func removeAllQueuedRequest() {
        WebServiceRequest.authRequestQueue.removeAll()
    }
    
    private func send(request: URLRequest, needsAuth: Bool, completion: @escaping (Result<Data?, NetworkError>) -> Void) {
        let confing = URLSessionConfiguration.ephemeral
        task = URLSession(configuration: confing).dataTask(with: request, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    if self.requestTimeOutRetryCounter == 0 {
                        completion(.failure(NetworkError.apiError(error?.localizedDescription ?? "")))
                    }
                    self.requestTimeOutRetryCounter -= 1
                    self.send(request: request, needsAuth: needsAuth, completion: completion)
                    return
                }
                guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                    completion(.failure(NetworkError.apiError("Unexpected Error")))
                    return
                }
                
                guard let fetchedData = data else {
                    completion(.failure(NetworkError.apiError("Invalid response")))
                    return
                }
                
                // 401 Unauthorized
                guard httpStatusCode != 401, httpStatusCode != 400, httpStatusCode != 403  else {
                    
                    debugPrint("WebServiceRequest NOT AUTHORIZED: httpStatusCode", httpStatusCode)
                    SCFileLogger.shared.write("WebServiceRequest -> send \(request.debugDescription) NOT AUTHORIZED: httpStatusCode = \(httpStatusCode)", withTag: .logout)
                    
                    
                    
                    if needsAuth == false {
                        SCFileLogger.shared.write("WebServiceRequest -> send : needsAuth == false returning with authFailure ( unathorised ) \(httpStatusCode)", withTag: .logout)
                        completion(.failure(NetworkError.apiError("Auth failure")))
                        return
                    }
                    
                    AuthProvider.shared.getNewAccessToken(completion: { (accessToken, userID, error) in
                        
                        guard accessToken != nil else {
                            
                            SCFileLogger.shared.write("WebServiceRequest send -> SCAuth.shared.getNewAccessToken failed with error \(error.debugDescription) ", withTag: .logout)
                            debugPrint("WebServiceRequest: Unauthorized\(httpStatusCode)")
                            completion(.failure(NetworkError.apiError("New Access token failed")))
                            return
                        }
                        
                        // restart that request again
                        guard let url = request.url,
                              let method = request.httpMethod else {
                            debugPrint("Unauthorized Request could not be restarted")
                            completion(.failure(NetworkError.apiError("Unauthorized Request could not be restarted")))
                            return
                        }
                        self.fetchData(from: url,
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
                            SCFileLogger.shared.write("WebServiceRequest -> send :  errorInfos.count == 0 ", withTag: .logout)
                            completion(.failure(NetworkError.apiError("")))
                            return
                        }
                        for errorInfo in errorInfos{
                            SCFileLogger.shared.write("WebServiceRequest -> send :  errorInfos > 0 -> \(errorInfo) ", withTag: .logout)
                            completion(.failure(NetworkError.apiError("")))
                        }
                    } else {
                        if httpStatusCode >= 300 {
                            SCFileLogger.shared.write("WebServiceRequest -> send :  httpStatusCode >= 300 (\(httpStatusCode) ", withTag: .logout)
                            completion(.failure(NetworkError.apiError("")))
                        } else {
                            //let test = String(decoding: fetchedData, as: UTF8.self)
                            SCFileLogger.shared.write("WebServiceRequest -> send :  completion(.success(fetchedData)) ", withTag: .logout)
                            completion(.success(fetchedData))
                        }
                    }
                    
                } catch {
                    debugPrint("WebServiceRequest: baseParsingFailed \(httpStatusCode)")
                    SCFileLogger.shared.write("WebServiceRequest -> send :  catch ( line 428 ) ", withTag: .logout)
                    completion(.failure(NetworkError.apiError("")))
                }
                
            }
        })
        task?.resume()
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
}
