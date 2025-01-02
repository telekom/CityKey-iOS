//
//  SCStatusOverlayView.swift
//  OSCA
//
//  Created by Michael on 19.05.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCStatusOverlayView: UIView {


    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    
    var actionHandler : (() -> Void)? = nil

    func showText(_ text : String, title: String?, textAlignment: NSTextAlignment){
        self.actionBtn.isHidden = true
        
        self.titleLbl.adaptFontSize()
        self.titleLbl.text = title
        self.titleLbl.isHidden =  title?.count == 0

        self.textLbl.adaptFontSize()
        self.textLbl.text = text
        self.textLbl.textAlignment = textAlignment
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true

        self.actionHandler = nil
    }
    
    func showText(_ text : String, title: String?, textAlignment:NSTextAlignment, btnTitle: String, btnImage: UIImage, btnColor: UIColor?, btnAction : (() -> Void)? = nil) {
        
        self.titleLbl.adaptFontSize()
        self.titleLbl.text = title
        self.titleLbl.isHidden =  title?.count == 0

        self.textLbl.adaptFontSize()
        self.textLbl.text = text
        self.textLbl.textAlignment = textAlignment
         
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true

        
        self.actionBtn.isHidden = false
        //self.actionBtn.setTitle(" " + "btnTitle".localized(), for: .normal)
        self.actionBtn.setTitle(" " + btnTitle, for: .normal)
        self.actionBtn.setTitleColor(btnColor ?? UIColor(named: "CLR_OSCA_BLUE")!, for: .normal)
        self.actionBtn.titleLabel?.adaptFontSize()
        self.actionBtn.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: btnColor ?? UIColor(named: "CLR_OSCA_BLUE")!), for: .normal)
        self.actionHandler = btnAction

    }

    func showActivity(title: String? = nil){
        self.actionBtn.isHidden = true
        
        self.titleLbl.adaptFontSize()
        self.titleLbl.text = title
        self.titleLbl.isHidden =  title?.count == 0

        self.textLbl.isHidden = true
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false

        self.actionHandler = nil

    }

    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
        
    @IBAction func actionBtnWasPressed(_ sender: Any) {
        actionHandler?()
    }
}
