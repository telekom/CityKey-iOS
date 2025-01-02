//
//  FeedbackConfirmationViewController.swift
//  OSCA
//
//  Created by Ayush on 09/09/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCFeedbackConfirmationViewController: UIViewController {
   
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var desclabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var submitButton: SCCustomButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    public var presenter: SCFeedbackConfirmationPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.adaptFontSize()
        self.presenter.setDisplay(self)
        self.submitButton.customizeBlueStyle()
        self.presenter.viewDidLoad()
   }
    
    private func setupUI() {
        self.navigationItem.title = "p_001_feedback_title".localized()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "icon_close"), style: .plain, target: self, action: #selector(closeButtonTapped)), animated: false)
        self.submitButton.setTitle("feedback_ok_button".localized(), for: .normal)
        
        titleLabel.text = "feedback_successful_submission_heading".localized()
        desclabel.attributedText = "feedback_successful_submission_description".localized().applyHyphenation()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs() {
        self.submitButton.accessibilityIdentifier = "btn_ok"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.desclabel.accessibilityIdentifier = "lbl_desc"
        
    }
    
    private func setupAccessibility() {
        self.submitButton.accessibilityTraits = .button
        self.submitButton.accessibilityLabel = "send_button"
        self.submitButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    private func adaptFontSize() {
        titleLabel.adaptFontSize()
        desclabel.adaptFontSize()
        
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: nil)
        
        desclabel.adjustsFontForContentSizeCategory = true
        desclabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: nil)
    }
    
    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButtontapped(_ sender: Any) {
        let viewControllers = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}

extension SCFeedbackConfirmationViewController: SCFeedbackConfirmationDisplaying {
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func setupUI(email : String){
        
    }

    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
}
