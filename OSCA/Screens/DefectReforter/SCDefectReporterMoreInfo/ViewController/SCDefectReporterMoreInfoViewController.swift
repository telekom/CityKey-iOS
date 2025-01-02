//
//  SCDefectReporterMoreInfoViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 07/05/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCDefectReporterMoreInfoViewController: UIViewController {

    var presenter : SCDefectReporterMoreInfoPresenting!
    var completionAfterDismiss: (() -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.setDisplay(self)
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
    }

}


extension SCDefectReporterMoreInfoViewController : SCDefectReporterMoreInfoViewDisplay {
    
    func setNavigationTitle(_ title : String) {
        self.navigationItem.title = title
    }
    
    func pushViewController(_ viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
