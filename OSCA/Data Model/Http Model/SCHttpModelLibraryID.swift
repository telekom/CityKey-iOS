//
//  SCHttpModelLibraryID.swift
//  SmartCity
//
//  Created by Robert Swoboda - Telekom on 08.05.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation

struct SCHttpModelLibraryResult: Decodable {
    let result: SCHttpModelLibraryID
    
    func toBarcodeModel() -> SCModelBarcodeID {
        return SCModelBarcodeID(id: self.result.id)
    }
}

struct SCHttpModelLibraryID: Decodable {
    let isSuccessful: Bool
    let id: String
}
