//
//  AusweisAuthWorkFlowViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 24/02/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

protocol SCAusweisAuthWorkFlowDisplay : SCDisplaying, AnyObject {
    
    func display(viewController : UIViewController)
    func push(viewController : UIViewController)
    func dismissWorkFlowController()
    func setNavigationTitle(title : String)
    func getCurrentViewController() -> UIViewController?
}

class SCAusweisAuthWorkFlowViewController: UIViewController {

    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var workflowNavigationController : UINavigationController?
    var presenter : SCAusweisAuthWorkflowPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupAccessibilityIDs()
        setupAccessibility()
        presenter.setDisplay(display: self)
        presenter.viewDidLoad()
                
    }
    
    func setupUI()  {
        
        self.backButton.title = "Back"
        self.navigationItem.leftBarButtonItem = nil
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.closeButton.accessibilityIdentifier = "btn_close_workflow"
    }

    private func setupAccessibility(){
     
        self.navigationItem.titleView?.accessibilityTraits = .staticText
        self.navigationItem.titleView?.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.closeButton.accessibilityTraits = .button
        self.closeButton.accessibilityLabel = "egov_accessibility_text_close_workflow_button".localized()
    }

    @IBAction func closeButtonClicked() {
        
        let quitAlert = UIAlertController(title: "egov_cancel_workflow_dialog_title".localized(), message: "egov_cancel_workflow_dialog_message".localized(), preferredStyle: .alert)

        quitAlert.addAction(UIAlertAction(title: "egov_cancel_workflow_dialog_cancel_button".localized(), style: .default, handler: nil ))

        quitAlert.addAction(UIAlertAction(title: "egov_cancel_workflow_dialog_ok_button".localized(), style: .default, handler: { (action) in
            
            self.presenter.handleWorkflowCloseButton()

        }))

        present(quitAlert, animated: true, completion: nil)

    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.workflowNavigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.presenter.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.presenter.viewDidAppear()
    }
    
// MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SegueWorkflowNavigationController" {
            workflowNavigationController = segue.destination as? UINavigationController
            workflowNavigationController?.delegate = self
            workflowNavigationController?.isNavigationBarHidden = true
            
        }
    }

}

// MARK: SCAusweisAuthWorkFlowDisplay
extension SCAusweisAuthWorkFlowViewController : SCAusweisAuthWorkFlowDisplay {
    
    func display(viewController: UIViewController) {
        
        workflowNavigationController?.setViewControllers([viewController], animated: false)
        
    }
    
    func push(viewController: UIViewController) {
        
        workflowNavigationController?.pushViewController(viewController, animated: true)
    }
    
    func dismissWorkFlowController() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setNavigationTitle(title : String) {
        
        self.workflowNavigationController?.topViewController?.title = title
        self.navigationItem.title = title
        self.navigationItem.titleView?.accessibilityLabel = title
        
    }
    
    func getCurrentViewController() -> UIViewController? {
        return workflowNavigationController?.topViewController
    }
}

// MARK: - UINavigationControllerDelegate
extension SCAusweisAuthWorkFlowViewController : UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            //self.navigationItem.leftBarButtonItem = self.backButton
            self.navigationItem.setLeftBarButton(self.backButton, animated: true)
        } else {
            //self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.setLeftBarButton(nil, animated: true)
            self.navigationItem.title = viewController.title
        }
        debugPrint("AUSWEIS Showing :\(viewController.debugDescription)")
    }
}
