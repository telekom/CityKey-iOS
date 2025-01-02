//
//  SCModelAusweisCertificate.swift
//  OSCA
//
//  Created by Bharat Jagtap on 12/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation


struct SCModelAusweisCertificate {
    var msg : String
    let issuerName : String
    let issuerUrl : String
    let subjectName : String
    let subjectUrl : String
    let termsOfUsage : String
    let purpose : String
    let effectiveDate : String
    let expirationDate : String
}

struct SCHTTPModelAusweisCertificate : Decodable {
    
    var msg : String
    var description : Description
    struct Description : Codable {
        let issuerName : String
        let issuerUrl : String
        let subjectName : String
        let subjectUrl : String
        let termsOfUsage : String
        let purpose : String
    }
   
    let validity: Validity
    struct Validity : Codable {
        let effectiveDate : String
        let expirationDate : String
    }
    
    func toModel() -> SCModelAusweisCertificate {
        
        return SCModelAusweisCertificate(msg: self.msg,
                                         issuerName: self.description.issuerName,
                                         issuerUrl: self.description.issuerUrl,
                                         subjectName: self.description.subjectName,
                                         subjectUrl: self.description.subjectUrl,
                                         termsOfUsage: self.description.termsOfUsage,
                                         purpose: self.description.purpose,
                                         effectiveDate: self.validity.effectiveDate,
                                         expirationDate: self.validity.expirationDate)        
    }
}
