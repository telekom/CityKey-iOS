//
//  SCShareContent.swift
//  SmartCity
//
//  Created by Michael on 09.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import MessageUI
import Messages

/**
 * This class contains class methods for sharing data
 */

class SCShareContent: NSObject {
    
    /**
     *
     * Class method to present a share activity. Curently only HTML eMail is
     * supported
     *
     * @param tittle for the shared message
     * @param url to share
     * @param sourceRect optional rect to present the activity
     */
    static func showShareActivity(title: String, url: String, sourceRect:CGRect?){
        var objectsToShare = [AnyObject]()
        
        if let appStoreLink = Bundle.main.infoDictionary?["SCShareAppstoreLink"] as? String {
            let msg = title + "\n" + url + "\n\n" + "share_store_header".localized() + "\n" + appStoreLink
            objectsToShare = [msg as AnyObject]
            
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.modalPresentationStyle = .popover
            //activityVC.excludedActivityTypes = [ UIActivity.ActivityType.postToFacebook, UIActivity.ActivityType.postToTwitter, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.message, UIActivity.ActivityType.print, UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.postToFlickr, UIActivity.ActivityType.postToVimeo,UIActivity.ActivityType.postToTencentWeibo,UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),
            //                                     UIActivity.ActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
            activityVC.setValue("share_store_header".localized() , forKey: "subject");
            activityVC.popoverPresentationController?.sourceView = SCUtilities.topViewController().view
            if let sourceRect = sourceRect {
                activityVC.popoverPresentationController?.sourceRect = sourceRect
            }

            SCUtilities.topViewController().present(activityVC, animated: true, completion: nil)
        }
    }

    static func share(objects: [Any], emailTitle: String, sourceRect: CGRect?) {
        let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        activityVC.setValue(emailTitle, forKey: "subject") ;
        activityVC.popoverPresentationController?.sourceView = SCUtilities.topViewController().view
        if let sourceRect = sourceRect {
            activityVC.popoverPresentationController?.sourceRect = sourceRect
        }

        SCUtilities.topViewController().present(activityVC, animated: true, completion: nil)
    }
}
