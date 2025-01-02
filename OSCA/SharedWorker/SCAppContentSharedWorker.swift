//
//  SCAppContentSharedWorker.swift
//  SmartCity
//
//  Created by Michael on 25.01.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAppContentPrivacySettingsOberserving {
    var privacyOptOutMoEngage: Bool { get set }
    var privacyOptOutAdjust: Bool { get set }
    func observePrivacySettings(completion: @escaping (Bool,Bool) -> Void)
}

protocol SCAppContentSharedWorking : SCAppContentPrivacySettingsOberserving {

    var firstTimeUsageFinished: Bool { get set }
    var isToolTipShown: Bool {get set}
    var switchLocationToolTipShouldBeShown: Bool { get set }
    var trackingPermissionFinished: Bool { get set }
    var isCityActive: Bool { get set }

    
    var termsDataState: SCWorkerDataState { get }
    
    func isNearestCityAvailable() -> Bool
    func updateNearestCity(cityId: Int)
    func storedNearestCity() -> Int
    
    func isDistanceToNearestLocationAvailable() -> Bool
    func updateDistanceToNearestLocation(distance: Double)
    func storedDistanceToNearestLocation() -> Double?
    
    func getDataSecurity() -> SCModelTermsDataSecurity?
    func getFAQLink() -> String?
    func getLegalNotice() -> String?
    func getTermsAndConditions() -> String?
    func triggerTermsUpdate(errorBlock: @escaping (SCWorkerError?)->())
    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void)
    
}

class SCAppContentSharedWorker: SCWorker {
    
    let storedTermsKey: String = "storedTermsKey"
    let storedPrivacyOptOutMoEngageKey: String = "storedPrivacyOptOutMoEngageKey"
    let storedPrivacyOptOutAdjustKey: String = "storedPrivacyOptOutAdjustKey"
    let storedFirstTimeUsageFinishedKey: String = "storedFirstTimeUsageFinishedKey"
    let storedLocationCityToolTipShouldBeShownKey: String = "storedLocationCityToolTipShouldBeShownKey"
    let storedNearestCityIdKey: String = "storedNearestCityIdKey"
    let storedDistanceToNearestLocationKey: String = "storedDistanceToNearestLocationKey"
    let storedTrackingPermissionFinishedKey: String = "storedTrackingPermissionFinishedKey"
    let storedIsCityActiveKey: String = "storedIsCityActive"
    let storedIsToolTipVisible: String = "storedIsToolTipVisible"


    internal var termsDataState = SCWorkerDataState()

    private var privacySettingsObserver: [(Bool,Bool) -> Void] = []

    internal var firstTimeUsageFinished: Bool {
        set {
            UserDefaults.init(suiteName: SCUtilities.getAppGroupId())?.set(newValue, forKey: storedFirstTimeUsageFinishedKey)
            UserDefaults.standard.set(newValue, forKey: self.storedFirstTimeUsageFinishedKey)
        }
        get {
           UserDefaults.standard.register(defaults: [storedFirstTimeUsageFinishedKey : false])
           return UserDefaults.standard.bool(forKey:storedFirstTimeUsageFinishedKey)
        }
    }

    internal var isToolTipShown: Bool {
        set {
           UserDefaults.standard.set(newValue, forKey: self.storedIsToolTipVisible)
         }
        get {
           UserDefaults.standard.register(defaults: [storedIsToolTipVisible : false])
           return UserDefaults.standard.bool(forKey:storedIsToolTipVisible)
        }
    }

    internal var switchLocationToolTipShouldBeShown: Bool {
        set {
           UserDefaults.standard.set(newValue, forKey: self.storedLocationCityToolTipShouldBeShownKey)
         }
        get {
           UserDefaults.standard.register(defaults: [storedLocationCityToolTipShouldBeShownKey : true])
           return UserDefaults.standard.bool(forKey:storedLocationCityToolTipShouldBeShownKey)
        }
    }
    
    internal var nearestLocationCityId: Int = -1
    
    internal var distanceToNearestLocation: Double = -1.0
    
    internal var trackingPermissionFinished: Bool {
        set {
           UserDefaults.standard.set(newValue, forKey: self.storedTrackingPermissionFinishedKey)
         }
        get {
           UserDefaults.standard.register(defaults: [storedTrackingPermissionFinishedKey : false])
           return UserDefaults.standard.bool(forKey:storedTrackingPermissionFinishedKey)
        }
    }
    
    internal var isCityActive: Bool {
        set {
           UserDefaults.standard.set(newValue, forKey: self.storedIsCityActiveKey)
         }
        get {
           UserDefaults.standard.register(defaults: [storedIsCityActiveKey : false])
           return UserDefaults.standard.bool(forKey:storedIsCityActiveKey)
        }
    }

    private var termsContent: SCModelTerms? {
        set {
           guard newValue != nil else {
               UserDefaults.standard.removeObject(forKey: storedTermsKey);
               return
           }
           let encodedData = try? PropertyListEncoder().encode(newValue)
           UserDefaults.standard.set(encodedData, forKey:storedTermsKey)
         }
        get {
           if let data = UserDefaults.standard.value(forKey:storedTermsKey) as? Data {
              return try? PropertyListDecoder().decode(SCModelTerms.self, from:data)
           
           }
          return nil
        }
    }

    public var privacyOptOutMoEngage: Bool {
        set {
           UserDefaults.standard.set(newValue, forKey:storedPrivacyOptOutMoEngageKey)
            // after change of privacy call the registered completion handler
             for completion in self.privacySettingsObserver {
                completion(newValue, self.privacyOptOutAdjust)
             }
         }
        get {
            UserDefaults.standard.register(defaults: [storedPrivacyOptOutMoEngageKey : true])
            return UserDefaults.standard.bool(forKey:storedPrivacyOptOutMoEngageKey)
        }
    }

    public var privacyOptOutAdjust: Bool {
        set {
           UserDefaults.standard.set(newValue, forKey:storedPrivacyOptOutAdjustKey)
             // after change of privacy call the registered completion handler
              for completion in self.privacySettingsObserver {
                completion(self.privacyOptOutMoEngage, newValue)
              }
         }
        get {
            UserDefaults.standard.register(defaults: [storedPrivacyOptOutAdjustKey : true])
            return UserDefaults.standard.bool(forKey:storedPrivacyOptOutAdjustKey)
        }
    }

    override init(requestFactory: SCRequestCreating,
                  appSharedDefaults: AppSharedDefaults = AppSharedDefaults()) {
        super.init(requestFactory: requestFactory, appSharedDefaults: appSharedDefaults)
    }

}


extension SCAppContentSharedWorker: SCAppContentSharedWorking {
    func storedNearestCity() -> Int {
        return self.nearestLocationCityId
    }
    
    func updateNearestCity(cityId: Int) {
        self.nearestLocationCityId = cityId
    }
    
    func isNearestCityAvailable() -> Bool {
        return self.nearestLocationCityId != -1
    }
    
    func isDistanceToNearestLocationAvailable() -> Bool {
        return self.distanceToNearestLocation != -1.0
    }
    
    func updateDistanceToNearestLocation(distance: Double) {
        self.distanceToNearestLocation = distance
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return self.distanceToNearestLocation
    }
    
    
    func observePrivacySettings(completion: @escaping (Bool,Bool) -> Void){
        self.privacySettingsObserver.append(completion)
    }

    func areTermsAvailable() -> Bool {
        return self.termsContent != nil
    }
    
    func areTermsLoading() -> Bool {
        return termsDataState.dataLoadingState == .fetchingInProgress
    }

    func isTermsLoadingFailed() -> Bool {
        return termsDataState.dataLoadingState == .fetchFailed
    }
    
    func getDataSecurity() -> SCModelTermsDataSecurity? {
        return self.termsContent?.dataSecurity
    }

    func getFAQLink() -> String? {
        return self.termsContent?.faq
    }

    func getTermsAndConditions() -> String? {
        return self.termsContent?.termsAndConditions
    }

    func getLegalNotice() -> String? {
        return self.termsContent?.legalNotice
    }

    func triggerTermsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        guard termsDataState.dataLoadingState != .fetchingInProgress else {
            SCUtilities.delay(withTime: 0.0, callback: {errorBlock(nil)})
            
            return
        }
        
        self.termsDataState.dataLoadingState = .fetchingInProgress

        self.fetchTerms() { (workerError, termsContent) in
            
            if workerError == nil {

                self.termsContent = termsContent
                self.termsDataState.dataInitialized = true
                self.termsDataState.dataLoadingState = .fetchedWithSuccess
                errorBlock(nil)
                NotificationCenter.default.post(name: .didReceiveTermsData, object: nil)
            } else {
                self.termsDataState.dataLoadingState = .fetchFailed
                errorBlock(workerError)
                NotificationCenter.default.post(name: .termsLoadingFailed, object: nil)
            }
        }
    }
            
    func clearStoredTerms() {
        self.termsContent = nil
        self.termsDataState = SCWorkerDataState()
    }
    
    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void) {
        
        let apiPath = "/api/v2/smartcity/userManagement"
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": String(cityID), "actionName": "PUT_UserDpnStatus", "dpnAccepted" : "true"] as [String : String]
        
        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "PUT", body: nil, needsAuth: true) { (response) in
            
            switch response {
                
            case .success(let fetchedData):
                do {
                    let type = SCHttpModelResponse<Int>.self
                    let termsResult = try JSONDecoder().decode(type, from: fetchedData)
                    completion(nil, termsResult.content)
                    
                } catch {
                    completion(SCWorkerError.technicalError,nil)
                }
                
            case .failure(let error):
                completion(self.mapRequestError(error), nil)
            }
        }
    }
    
}

extension SCAppContentSharedWorker {
    
    private func fetchTerms(completion: @escaping (SCWorkerError?, SCModelTerms?) -> Void) {
        
        let apiPath = "/api/v2/smartcity/city/cityService"
        
        #if INT
            let cityID = "10"
        #else
            let cityID = "8"
        #endif

        let queryDictionary = ["cityId": String(cityID), "actionName": "GET_Terms"] as [String : String]
        let url = GlobalConstants.appendURLPathToSOLUrl(path: apiPath, parameter: queryDictionary)
        
        request.fetchData(from: url, method: "GET", body: nil, needsAuth: false) { (response) in
            
            switch response {
                
            case .success(let fetchedData):
                do {
                    let type = SCHttpModelResponse<[SCModelTerms]>.self
                    let termsResult = try JSONDecoder().decode(type, from: fetchedData)
                    completion(nil, termsResult.content.first)
                    
                } catch {
                    completion(SCWorkerError.technicalError,nil)
                }
                
            case .failure(let error):
                SCFileLogger.shared.write("Harshada -> fetchTerms | SCAppContentSharedWorker: requestFailed-> \(String(describing: error)) for \(url)", withTag: .logout)

                completion(self.mapRequestError(error), nil)
            }
        }
    }

}
