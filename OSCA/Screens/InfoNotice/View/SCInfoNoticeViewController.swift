//
//  SCInfoNoticeViewController.swift
//  SmartCity
//
//  Created by Michael on 01.02.20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

class SCInfoNoticeViewController: UIViewController {

    public var presenter: SCInfoNoticePresenting!

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.shouldNavBarTransparent = false
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "nvitem_btn_right"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeBtnWasPressed()
    }

    private func set(title: String) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
        titleLabel.text = title
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor(named: "CLR_NAVBAR_SOLID_TITLE")
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
}

extension SCInfoNoticeViewController: SCInfoNoticeDisplaying {
    
    func setupUI(title: String, topText: NSAttributedString, displayActIndicator: Bool) {
        set(title: title)
        self.navigationItem.backBarButtonItem?.title = ""
        
        if displayActIndicator{
            let activityIndicator = UIActivityIndicatorView()
            activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height)
            activityIndicator.backgroundColor = UIColor(named: "CLR_BCKGRND")
            if #available(iOS 13.0, *) {
                activityIndicator.style = .medium
            } else {
                activityIndicator.style = .gray
            }
            
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            
            DispatchQueue.main.async {
                self.topTextView.attributedText = topText
                self.topTextView.setNeedsLayout()
                self.topTextView.setNeedsUpdateConstraints()
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        } else {
            self.topTextView.attributedText = topText
            self.topTextView.setNeedsLayout()
            self.topTextView.setNeedsUpdateConstraints()
        }
        
        self.view.setNeedsLayout()
        self.stackView.invalidateIntrinsicContentSize()
    }
    
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}
