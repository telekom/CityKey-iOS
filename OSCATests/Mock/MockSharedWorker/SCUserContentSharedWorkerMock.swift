//
//  SCUserContentSharedWorkerMock.swift
//  OSCATests
//
//  Created by Bhaskar N S on 13/06/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
@testable import OSCA

class SCUserContentSharedWorkerMock: SCUserContentSharedWorking {
    
    var userDataState =  SCWorkerDataState()
    var infoBoxDataState = SCWorkerDataState()
    var profileModel: SCModelProfile?
    func observeUserID(completion: @escaping (String?) -> Void) {
        
    }
    
    func getCityID() -> String? {
        return "city1"
    }
    
    func observeCityID(completion: @escaping (String?) -> Void) {
        
    }
    
    func isUserDataLoadingFailed() -> Bool {
        return false
    }
    
    func getUserID() -> String? {
        return "id1"
    }
    
    func isUserDataAvailable() -> Bool {
        return true
    }
    
    func isUserDataLoading() -> Bool {
        return false
    }
    
    func getUserData() -> SCModelUserData? {
        let profile = SCModelProfile(accountId : 2, birthdate: Date(timeIntervalSince1970: TimeInterval(1561780587)), email: "test@tester.de", postalCode: "63739", homeCityId: 10, cityName: "Teststadt", dpnAccepted: true)

        return SCModelUserData(userID: "2", cityID: "10", profile: profileModel ?? profile)
    }
    
    func triggerUserDataUpdate(errorBlock: @escaping (SCWorkerError?) -> ()) {
        errorBlock(nil)
    }
    
    func isInfoBoxDataAvailable() -> Bool {
        return true
    }
    
    func isInfoBoxDataLoading() -> Bool {
        return false
    }
    
    func isInfoBoxDataLoadingFailed() -> Bool {
        return false
    }
    
    func getInfoBoxData() -> [SCModelInfoBoxItem]? {
        return [SCModelInfoBoxItem(userInfoId: 1, messageId: 1, description: "Info1", details: "More Details", headline: "Messahe Headline", isRead: false,  creationDate: dateFromString(dateString: "2019-08-01 00-00-00")!, category: SCModelInfoBoxItemCategory(categoryIcon: "icon.png", categoryName: "category1"), buttonText: "ok", buttonAction: "", attachments: [])]
    }

    
    func triggerInfoBoxDataUpdate(errorBlock: @escaping (SCWorkerError?)->()){
        errorBlock(nil)
    }

    func markInfoBoxItem(id : Int, read : Bool) {
        
    }
    
    func removeInfoBoxItem(id : Int){
        
    }
    
    func clearData(){
        
    }
    
}
