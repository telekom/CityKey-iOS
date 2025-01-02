//
//  SCFeedbackConfirmationPresenter.swift
//  OSCA
//
//  Created by Ayush on 09/09/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCFeedbackConfirmationDisplaying: AnyObject, SCDisplaying  {
    
    func dismiss(completion: (() -> Void)?)
    func push(viewController: UIViewController)
}

protocol SCFeedbackConfirmationPresenting: SCPresenting {
    func setDisplay(_ display: SCFeedbackConfirmationDisplaying)
}

class SCFeedbackConfirmationPresenter: NSObject {
    weak private var display : SCFeedbackConfirmationDisplaying?
    
    private let injector: SCToolsInjecting
    private weak var presentedVC: UIViewController?
    
    init(injector: SCToolsInjecting) {
        self.injector = injector
    }
}

extension SCFeedbackConfirmationPresenter: SCFeedbackConfirmationPresenting {
    func setDisplay(_ display: SCFeedbackConfirmationDisplaying) {
        self.display = display
    }
    
    func viewDidLoad() {
        // setup any ui
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
}
    
