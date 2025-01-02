//
//  SCDisplayHelper.swift
//  SmartCity
//
//  Created by Michael on 13.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

enum displayContentType {
    case news
    case proposal
    case userinfo
    case service
    case marketplace
}

/**
 * This class holds some funtions to help Controllers to display
 * content and informations
 */

class SCDisplayHelper: NSObject, UIViewControllerTransitioningDelegate {

    static let transitionDelegate = SCBubbleTransitionDelegate()
    
    var startPoint : CGPoint?

    /**
     *
     * Class method to show detailed messages, city content, userinfos
     *
     * @param viewController The view controller who should present the  controller
     * @param url if this parameter is set, the content of the url will be presented
     *         in the webcontent controller
     * @param htmlString if the url is set to nil then the controller will prseent the content
     *          of the htmlString
     * @param title the title for the navigation bar
     */
    static func showContent(for viewController: UIViewController,
                            displayContentType : displayContentType,
                            navTitle : String,
                            title : String,
                            teaser : String,
                            details : String?,
                            imageURL : SCImageURL?,
                            topBtnTitle : String?,
                            bottomBtnTitle : String?,
                            contentURL : URL?,
                            serviceFunction :  String? = nil,
                            lockedDueAuth : Bool? = false,
                            lockedDueResidence : Bool? = false,
                            topBtnCompletion: (() -> Void)? = nil,
                            bottomBtnCompletion: (() -> Void)? = nil) {
        
        
        var storyboardID : String!
        
        switch displayContentType {
        case .news:
            storyboardID = "MessageDetailType2"
        case .proposal:
            storyboardID = "MessageDetailType2"
        case .userinfo:
            storyboardID = "MessageDetailType1"
        case .service:
            storyboardID = "MessageDetailType2"
        case .marketplace:
            storyboardID = "MessageDetailType2"
        }
        
        let navViewController:UINavigationController = UIStoryboard(name: "MessageDetailScreen", bundle: nil).instantiateViewController(withIdentifier: storyboardID) as! UINavigationController
        let contentController = navViewController.viewControllers[0] as! SCMessageDetailVC
        navViewController.transitioningDelegate = transitionDelegate
        navViewController.modalPresentationStyle = .overCurrentContext
        navViewController.presentAboveTabbar()
        
             contentController.setContent(navTitle : navTitle,
                                         title : title,
                                         teaser : teaser,
                                         details : details,
                                         imageURL : imageURL,
                                         topBtnTitle : topBtnTitle,
                                         bottomBtnTitle : bottomBtnTitle,
                                         contentURL : contentURL,
                                         lockedDueAuth : lockedDueAuth,
                                         lockedDueResidence : lockedDueResidence,
                                         topBtnCompletion: topBtnCompletion,
                                         bottomBtnCompletion: bottomBtnCompletion)
    
        
 
        
        
        viewController.present(navViewController, animated: true, completion: nil)
    }


    
}
