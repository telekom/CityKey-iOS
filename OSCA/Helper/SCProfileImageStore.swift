//
//  SCProfileImageStore.swift
//  SmartCity
//
//  Created by Michael on 07.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCProfileImageStore {

    static private var uuid : String?
    static private var profile_image : String?

    static func storeEncodedProfileImage(_ image : String, uuid : String){
        SCProfileImageStore.uuid = uuid
        SCProfileImageStore.profile_image = image
    }

    static func clearStoredProfileImage(){
        SCProfileImageStore.uuid = nil
        SCProfileImageStore.profile_image = nil
    }
    
    static func isImageAvailable(uuid : String) -> Bool{
        if SCProfileImageStore.uuid == uuid {
            return true
        }
        return false
    }

    static func image(for uuid : String) -> UIImage?{
        if SCProfileImageStore.isImageAvailable(uuid: uuid) {
            let encodedImage = SCProfileImageStore.profile_image
            let image = encodedImage?.imageFromBase64()
            return image
        }
        return nil
     }
}
