//
//  SCAppContentWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 08/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

@testable import OSCA

class SCAppContentWorkerMock: SCAppContentSharedWorking {
    var acceptDataPrivacyNoticeChangeError: SCWorkerError?
    var acceptDataPrivacyNoticeChangeCount: Int?
    
    init(acceptDataPrivacyNoticeChangeError: SCWorkerError? = nil, count: Int? = 0) {
        self.acceptDataPrivacyNoticeChangeError = acceptDataPrivacyNoticeChangeError
        self.acceptDataPrivacyNoticeChangeCount = count
    }

    func acceptDataPrivacyNoticeChange(completion: @escaping (SCWorkerError?, Int?) -> Void) {
        completion(acceptDataPrivacyNoticeChangeError,
                   acceptDataPrivacyNoticeChangeCount)
    }
    
    func isNearestCityAvailable() -> Bool {
        return false
    }
    
    func updateNearestCity(cityId: Int) {
        
    }
    
    func storedNearestCity() -> Int {
        return 0
    }
    
    func isDistanceToNearestLocationAvailable() -> Bool {
        return false
    }
    
    func updateDistanceToNearestLocation(distance: Double) {
        
    }
    
    func storedDistanceToNearestLocation() -> Double? {
        return 0.0
    }
    

    var termsDataState =  SCWorkerDataState()

    var firstTimeUsageFinished: Bool = true
    
    var switchLocationToolTipShouldBeShown: Bool = true

    var trackingPermissionFinished: Bool = true
    
    func getDataSecurity() -> SCModelTermsDataSecurity? {
        return nil
    }

    var isToolTipShown: Bool = true
    
    var privacyOptOutMoEngage: Bool = true
    
    var privacyOptOutAdjust: Bool = true
     
    var isCityActive: Bool = true

    func getDataPrivacyLink() -> String? {
        return nil
    }
    
    func observePrivacySettings(completion: @escaping (Bool, Bool) -> Void) {
        
    }
    
    func getFAQLink() -> String? {
        return nil
    }
    
    func getLegalNotice() -> String? {
        return nil
    }
    
    func getTermsAndConditions() -> String? {
        return nil
    }
    
    func triggerTermsUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        
    }
    

}
