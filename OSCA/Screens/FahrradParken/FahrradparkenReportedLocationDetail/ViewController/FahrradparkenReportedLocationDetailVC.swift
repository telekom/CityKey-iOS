//
//  FahrradparkenLocationDetailsVC.swift
//  OSCA
//
//  Created by Bhaskar N S on 22/05/23.
//  Copyright © 2023 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class FahrradparkenReportedLocationDetailVC: UIViewController {
    
    @IBOutlet weak var mainCategotyLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var serviceRequestIdLabel: UILabel!
    @IBOutlet weak var serviceDescriptionLabel: UILabel!
    @IBOutlet weak var serviceStatusLabel: UILabel!
    @IBOutlet weak var serviceStatusView: UIView!
    @IBOutlet weak var detailIcon: UIImageView!
    @IBOutlet weak var mainCategoryView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var moreInformationBtnLabel: UILabel!
    
    
    var presenter: FahrradparkenReportedLocationDetailPresenting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAccessibility()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
    }
    
    @IBAction func moreInformationTapped(_ sender: Any) {
        if let urlStr = presenter.getMoreInformationUrl(),
           let url = URL(string: urlStr),
           UIApplication.shared.canOpenURL(url) {
            SCInternalBrowser.showURL(url, withBrowserType: .safari)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.view.backgroundColor = .clear
        self.dismiss(animated: true) { [weak self] in
            self?.presenter.handleCompletion()
        }
    }
}
