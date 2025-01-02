//
//  SCModelAusweisAccessRights.swift
//  OSCA
//
//  Created by Bharat Jagtap on 12/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCModelAusweisAccessRights  {
    
    let msg : String
    let error : String?
    let transactionInfo : String?
    let canAllowed : Bool?
    
    // values from 'aux'
    let ageVerificationDate : String?
    let requiredAge : String?
    let validityDate : String?
    let communityId : String?
    
    // values from 'chat'
    let effective : [String]
    let chatOptional : [String]
    let chatRequired : [String]

//    init(msg: String, error: String?, transactionInfo: String?, canAllowed: Bool?, ageVerificationDate: String?, requiredAge: String?, validityDate: String?, communityId: String?, effective: String, chatOptional: String, chatRequired: String) {
//
//        self.msg = msg
//        self.error = error
//        self.transactionInfo = transactionInfo
//        self.canAllowed = canAllowed
//        self.ageVerificationDate = ageVerificationDate
//        self.requiredAge = requiredAge
//        self.validityDate = validityDate
//        self.communityId = communityId
//        self.effective = effective
//        self.chatOptional = chatOptional
//        self.chatRequired = chatRequired
//    }
    
}

struct SCHTTPModelAusweisAccessRights: Decodable {
    
    let msg : String
    let error : String?
    
    let aux: Aux?
    struct Aux: Decodable {
        let ageVerificationDate, requiredAge, validityDate, communityId: String?
    }
    
    let chat: Chat
    struct Chat: Decodable {
        let effective, chatOptional, chatRequired: [String]
        enum CodingKeys: String, CodingKey {
            case effective = "effective"
            case chatOptional = "optional"
            case chatRequired = "required"
        }
    }
    
    let transactionInfo: String?
    let canAllowed: Bool?
    
    
    func toModel() -> SCModelAusweisAccessRights {
        
       // return SCModelAusweisAccessRights(msg: self.msg, error: self.error, transactionInfo: self.transactionInfo, canAllowed: self.canAllowed, ageVerificationDate: self.aux?.ageVerificationDate, requiredAge: self.aux?.requiredAge, validityDate: self.aux?.validityDate, communityId: self.aux?.communityId, effective: self.chat.effective, chatOptional: self.chat.chatOptional, chatRequired: self.chat.chatRequired)
        
        
        return SCModelAusweisAccessRights(msg: self.msg,
                                          error: self.error,
                                          transactionInfo: self.transactionInfo,
                                          canAllowed: self.canAllowed,
                                          ageVerificationDate: self.aux?.ageVerificationDate,
                                          requiredAge: self.aux?.requiredAge,
                                          validityDate: self.aux?.validityDate,
                                          communityId: self.aux?.communityId,
                                          effective: self.chat.effective.map { "egov_sdk_\($0)".localized() },
                                          chatOptional: self.chat.chatOptional,
                                          chatRequired: self.chat.chatRequired)
         
    }
}
