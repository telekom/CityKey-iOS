/*
Created by Bharat Jagtap on 29/10/21.
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
import WebKit

protocol SCEgovServiceLongDescriptionDisplay : SCDisplaying, AnyObject {
    func setHtmlDescription(text : NSAttributedString)
    func setServiceLinks(_ links: [SCModelEgovServiceLink])
    func pushViewController(_ controller: UIViewController)
}

class SCEgovServiceLongDescriptionViewController: UIViewController {
    
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var tableView: UITableView!
    var presenter : SCEgovServiceLongDescriptionPresenting!
    var egovServices: [SCModelEgovServiceLink]?
    @IBOutlet weak var tableHeaderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter.setDisplay(self)
        presenter.viewDidLoad()
        self.navigationItem.title = presenter.getTitle()
    }
    
    func setupUI() {
        setupTableView()
        self.textView.layoutManager.hyphenationFactor = 1.0
    }
    
    fileprivate func setupTableView() {
        registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = GlobalConstants.kEgovServiceDetailCellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = GlobalConstants.kEgovServiceDetailsTableHeaderHeight
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0);
    }
    
    fileprivate func registerTableViewCells() {
        tableView.register(UINib(nibName: "EgovServiceLinkCell", bundle: nil),
                           forCellReuseIdentifier: "EgovServiceLinkCell")
    }
}

extension SCEgovServiceLongDescriptionViewController :  SCEgovServiceLongDescriptionDisplay {
    
    func setHtmlDescription(text: NSAttributedString) {
        textView.attributedText = text
        textView.linkTextAttributes = [.foregroundColor: kColor_cityColor]
        resize(textView: textView)
    }
    
    func setServiceLinks(_ links: [SCModelEgovServiceLink]) {
        self.egovServices = links
        tableView.reloadData()
    }
        
    func pushViewController(_ controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }

    fileprivate func resize(textView: UITextView) {
        var newFrame = textView.frame
        let width = newFrame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: width,
                                                   height: newFrame.size.height))
        newFrame.size = CGSize(width: width, height: newSize.height)
        textView.frame = newFrame
        tableHeaderView.frame = newFrame
    }
}
