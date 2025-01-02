//
//  SCActivityViewHandler.swift
//  SmartCity
//
//  Created by Michael on 25.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 * This class provides methods for presenting activity views
 */
class SCActivityViewHandler {
    
    var activityViewController : SCActivityViewController?
    var parentViewController : UIViewController?
    
    
    static let sharedInstance = SCActivityViewHandler()
    
    private init() {
        
    }
    
    /**
     *
     * Method to present an AcitivyIndcator screen
     *
     * @param viewController The view controller who should present the indcator screen controller
     * @param animated TRUE if the screen should be presented with an animation
     */
    func presentActivityView(on viewcontroller: UIViewController, animated: Bool) {
        if activityViewController == nil {
            self.parentViewController = viewcontroller
            self.activityViewController = (UIStoryboard(name: "ActivityScreen", bundle: nil).instantiateViewController(withIdentifier: "activityViewController") as! SCActivityViewController)
            viewcontroller.present(self.activityViewController!, animated: animated, completion: nil)
            
        }
    }
    
    /**
     *
     * Method to dismiss an AcitivyIndcator screen
     *
     * @param viewController The view controller which is presenting the indcator screen controller
     * @param animated TRUE if the screen should be dismissed with an animation
     */
    func dismissActivityView(from viewcontroller: UIViewController, animated: Bool) {
        if (self.activityViewController != nil && self.parentViewController == viewcontroller) {
            self.parentViewController!.dismiss(animated: animated, completion: nil)
            self.activityViewController = nil
            self.parentViewController = nil
        }
        
    }
    
}
