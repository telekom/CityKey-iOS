//
//  SCTempBlockedVC.swift
//  SmartCity
//
//  Created by Michael on 19.02.20
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCTempBlockedVC: UIViewController {
  
    public var presenter: SCTempBlockedPresenter!

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var resetBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAccessibilityIDs()
        self.shouldNavBarTransparent = false
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()

        self.view.setNeedsLayout()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.topImageView.accessibilityIdentifier = "img_top"
        self.titleLabel.accessibilityIdentifier = "lbl_title"
        self.resetBtn.accessibilityIdentifier = "btn_reset"
        self.resetLabel.accessibilityIdentifier = "lbl_reset"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }


    @IBAction func resetBtnWasPressed(_ sender: Any) {
        self.presenter.resetWasPressed()
    }
    
    @IBAction func closeButtonWasPressed(_ sender: UIBarButtonItem) {
        self.presenter.finishWasPressed()
    }
}

extension SCTempBlockedVC: SCTempBlockedDisplaying {
    func setupNavigationBar(title: String){
        self.navigationItem.title = title
        // remove the Back button
        self.navigationItem.hidesBackButton = true
    }
    
    func setupUI(){
        self.titleLabel.adaptFontSize()
        self.titleLabel.text = "f_001_temp_blocked_main_label".localized()
        self.resetLabel.adaptFontSize()
        self.resetLabel.text = "f_001_temp_blocked_hint_label".localized()
        self.resetBtn.setTitle("f_001_temp_blocked_reset_btn".localized(), for: .normal)
        self.resetBtn.titleLabel?.adaptFontSize()
        
        self.view.setNeedsLayout()
        // Do any additional setup after loading the view.
        
        
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func dismissView(completion: (() -> Void)? = nil) {
        self.dismiss(animated: false, completion: completion)
    }

}
