//
//  SCInfoNoticePresenter.swift
//  SmartCity
//
//  Created by Michael on 01.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCInfoNoticeDisplaying: AnyObject, SCDisplaying {
    func setupUI(title: String,
                 topText: NSAttributedString,
                 displayActIndicator: Bool)
    
    func dismiss()

}

protocol SCInfoNoticePresenting: SCPresenting {
    func setDisplay(_ display: SCInfoNoticeDisplaying)
    func closeBtnWasPressed()
}

class SCInfoNoticePresenter {
    
    weak private var display: SCInfoNoticeDisplaying?
    private let injector: SCAdjustTrackingInjection
    private let title: String
    private let content: String

    init(title: String, content: String, injector: SCAdjustTrackingInjection) {
        
        self.title = title
        self.content = content
        self.injector = injector
    }
        
}

extension SCInfoNoticePresenter: SCPresenting {
    func viewDidLoad() {
        
        var topText = NSAttributedString(string: "")
        
        if let attrStringTop =  content.htmlAttributedString {
            let htmlAttrToptring = NSMutableAttributedString(attributedString: attrStringTop)
            htmlAttrToptring.replaceFont(with: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular), color: UIColor(named: "CLR_LABEL_TEXT_BLACK")!)
            topText = htmlAttrToptring

        }

        self.display?.setupUI(title: title,
                              topText:  topText,
                              displayActIndicator : true)
    }

    func viewWillAppear() {
    }
    
    func viewDidAppear() {
    }
}

extension SCInfoNoticePresenter : SCInfoNoticePresenting {

    func setDisplay(_ display: SCInfoNoticeDisplaying) {
        self.display = display
    }
    
    func closeBtnWasPressed(){
        self.display?.dismiss()
    }
}

