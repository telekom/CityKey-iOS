/*
Created by Bharat Jagtap on 21/04/21.
Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 
In accordance with Sections 4 and 6 of the License, the following exclusions apply:

    1. Trademarks & Logos – The names, logos, and trademarks of the Licensor are not covered by this License and may not be used without separate permission.
    2. Design Rights – Visual identities, UI/UX designs, and other graphical elements remain the property of their respective owners and are not licensed under the Apache License 2.0.
    3: Non-Coded Copyrights – Documentation, images, videos, and other non-software materials require separate authorization for use, modification, or distribution.

These elements are not considered part of the licensed Work or Derivative Works unless explicitly agreed otherwise. All elements must be altered, removed, or replaced before use or distribution. All rights to these materials are reserved, and Contributor accepts no liability for any infringing use. By using this repository, you agree to indemnify and hold harmless Contributor against any claims, costs, or damages arising from your use of the excluded elements.

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bharat Jagtap
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol  SCEgovServicesListViewDisplay : SCDisplaying, AnyObject {
    
    func reloadServicesList(_ serviceList : [SCModelEgovService])
    func setNavigationTitle(_ title : String)
    func pushViewController(_ viewController : UIViewController)

}

class SCEgovServicesListViewController: UIViewController {
    
    @IBOutlet weak var tableView : UITableView!
    var presenter : SCEgovServicesListPresenting!
    private var serviceList : [SCModelEgovService]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.setDisplay(self)
        tableView.dataSource = self
        tableView.delegate = self
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backButtonTitle = "navigation_bar_back".localized()
        self.navigationItem.backBarButtonItem?.accessibilityLabel = "navigation_bar_back".localized()

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                
                if let indexPaths = tableView.indexPathsForVisibleRows {
                    tableView.reloadRows(at: indexPaths, with: .none)
                }
            }
        }
    }
    
}

extension SCEgovServicesListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return serviceList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SCEgovServiceCell", for: indexPath) as! SCEgovServiceCell
        customizeCell(cell: cell, withModel: serviceList?[indexPath.section])
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let service = serviceList?[indexPath.section] {
            presenter.didSelectService(service)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }

    func customizeCell(cell : SCEgovServiceCell , withModel model : SCModelEgovService?) {

        if let model = model {
            cell.titleLabel.text = presenter.getServiceTitle(service: model)
            cell.typeLabel.text = presenter.getServiceLinkTitle(service: model)
            cell.typeImageView.image = presenter.getServiceIcon(service: model).maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray )
            cell.descLabel.attributedText = presenter.getServiceDescription(service: model).applyHyphenation()

            
            cell.accessibilityElements = [cell.titleLabel!, cell.descLabel!, cell.typeLabel!]
            cell.titleLabel.accessibilityLabel = presenter.getServiceTitle(service: model)
            cell.titleLabel.accessibilityTraits = .staticText
            cell.titleLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            
            cell.descLabel.accessibilityLabel = presenter.getServiceDescription(service: model)
            cell.descLabel.accessibilityTraits = .staticText
            cell.descLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            
            cell.typeLabel.accessibilityLabel = presenter.getServiceLinkTitle(service: model)
            cell.typeLabel.accessibilityTraits = .button
            cell.typeLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        } else {
        
            cell.titleLabel.text = ""
            cell.typeLabel.text = ""
            cell.descLabel.text = ""
            cell.typeImageView.image = nil
        }
    }
}

extension SCEgovServicesListViewController : SCEgovServicesListViewDisplay {
    
    func reloadServicesList(_ serviceList : [SCModelEgovService]) {
        
        self.serviceList = serviceList
        
        if serviceList.count == 0 {
            
            showText(on: self.view, text: "poi_002_error_text".localized(), title: "", textAlignment: .center)

        } else {
        
            tableView.reloadData()
        }
    }

    func setNavigationTitle(_ title : String) {
        self.navigationItem.title = title
    }
    
    func pushViewController(_ viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
