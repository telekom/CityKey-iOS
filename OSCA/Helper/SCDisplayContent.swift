//
//  SCDisplayContent.swift
//  SmartCity
//
//  Created by Michael on 18.07.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDisplayContent: NSObject {

    static func getMessageDetailController(displayContentType : SCDisplayContentType,
                                           navTitle : String,
                                           title : String,
                                           teaser : String,
                                           subtitle : String,
                                           details : String?,
                                           imageURL : SCImageURL?,
                                           photoCredit : String?,
                                           contentURL : URL?,
                                           tintColor : UIColor?,
                                           serviceFunction :  String? = nil,
                                           lockedDueAuth : Bool? = false,
                                           lockedDueResidence : Bool? = false,
                                           btnActions: [SCComponentDetailBtnAction]? = nil,
                                           injector: SCInjecting & SCAdjustTrackingInjection & SCWebContentInjecting,
                                           serviceType: String? = nil,
                                           itemServiceParams : [String:String]? = nil,
                                           beforeDismissCompletion :  (() -> Void)? = nil) -> UIViewController {
        
        var storyboardID : String!
        
        switch displayContentType {
        case .news:
            storyboardID = "MessageDetailType2"
        case .proposal:
            storyboardID = "MessageDetailType2"
        case .service:
            storyboardID = "ServicesInfoDetailVC"
        case .marketplace:
            storyboardID = "MessageDetailType2"
        }
        
        if displayContentType != .service{
            let navViewController:UINavigationController = UIStoryboard(name: "MessageDetailScreen", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! UINavigationController
            let contentController = navViewController.viewControllers[0] as! SCMessageDetailVC
            
            contentController.displayContentType = displayContentType
            
            contentController.setContent(navTitle : navTitle,
                                         title : title,
                                         teaser : teaser,
                                         subtitle: subtitle,
                                         details : details,
                                         imageURL : imageURL,
                                         photoCredit : photoCredit,
                                         contentURL : contentURL,
                                         tintColor : tintColor,
                                         lockedDueAuth : lockedDueAuth,
                                         lockedDueResidence : lockedDueResidence,
                                         btnActions: btnActions,
                                         injector: injector,
                                         beforeDismissCompletion : beforeDismissCompletion)
            return contentController
        }
        else{
            let navViewController:UINavigationController = UIStoryboard(name: "ServicesInfoDetailScreen", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! UINavigationController
            let contentController = navViewController.viewControllers[0] as! SCServicesInfoDetailVC
            
            contentController.displayContentType = displayContentType
            
            contentController.setContent(navTitle : navTitle,
                                         details : details,
                                         imageURL : imageURL,
                                         photoCredit : photoCredit,
                                         contentURL : contentURL,
                                         tintColor : tintColor,
                                         lockedDueAuth : lockedDueAuth,
                                         lockedDueResidence : lockedDueResidence,
                                         btnActions: btnActions,
                                         injector: injector,
                                         serviceType: serviceType,
                                         function: serviceFunction,
                                         itemServiceParams: itemServiceParams,
                                         beforeDismissCompletion : beforeDismissCompletion)
            return contentController
        }
    }
}
