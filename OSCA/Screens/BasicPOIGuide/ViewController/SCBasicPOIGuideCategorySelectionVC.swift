//
//  SCBasicPOIGuideCategorySelectionVC.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 09/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCBasicPOIGuideCategorySelectionVC: UIViewController {
    
    public var presenter: SCBasicPOIGuidePresenting!
        
    var categoryTableViewController : SCBasicPOIGuideCategorySelectionTableVC?
    var completionAfterDismiss: (() -> Void)? = nil
    
    @IBOutlet weak var closeBtn: UIBarButtonItem!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shouldNavBarTransparent = false
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
    
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        registerForNotification()
    }

    private func registerForNotification() {
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }

    @objc private func handleDynamicTypeChange() {
        categoryTableViewController?.tableView.reloadData()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.closeBtn.accessibilityIdentifier = "btn_close"
        self.retryButton.accessibilityIdentifier = "btn_retry_error"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }
    
    private func setupAccessibility(){
        self.closeBtn.accessibilityTraits = .button
        self.closeBtn.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideCategorySelectionVC.poi002CloseButtonContentDescription.localized()
        self.closeBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.retryButton.accessibilityTraits = .button
        self.retryButton.accessibilityLabel = LocalizationKeys.SCBasicPOIGuideCategorySelectionVC.poi001RetryButtonDecription.localized()
        self.retryButton.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
//        self.navigationItem.titleView?.accessibilityLabel = self.navigationItem.title
//        self.navigationItem.titleView?.accessibilityTraits = .staticText
//        self.navigationItem.titleView?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.viewWillAppear()
        self.refreshNavigationBarStyle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismiss()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let categoryTableViewController as SCBasicPOIGuideCategorySelectionTableVC:
            categoryTableViewController.delegate = self
            self.categoryTableViewController = categoryTableViewController
            break
        default:
            break
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    @IBAction func closeBtnWasPressed(_ sender: UIButton) {
        self.presenter.closeButtonWasPressed()
    }
    
    @IBAction func retryBtnWasPressed(_ sender: Any) {
        self.presenter.didPressGeneralErrorRetryBtn()
    }
}

// MARK: - SCBasicPOIGuideCategorySelectionTableVCDelegate
extension SCBasicPOIGuideCategorySelectionVC : SCBasicPOIGuideCategorySelectionTableVCDelegate {

    func categoryWasSelected(categoryName: String, categoryID : Int, categoryGroupIcon: String){
        self.presenter.categoryWasSelected(categoryName: categoryName, categoryID: categoryID, categoryGroupIcon: categoryGroupIcon)
    }
    
}
