/*
Created by Bhaskar N S on 06/05/24.
Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Bhaskar N S
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

extension SCEgovServiceLongDescriptionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let egovServices = egovServices,
                !egovServices.isEmpty else {
            return 0
        }
        return egovServices.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let egovServices = egovServices,
                !egovServices.isEmpty else {
            return 0
        }
        return egovServices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EgovServiceLinkCell",
                                                       for: indexPath) as? EgovServiceLinkCell,
              let egovServices = egovServices else {
            return UITableViewCell()
        }
        let link = egovServices[indexPath.row]
        cell.linkTitle.text = presenter.getServiceLinkTitle(link: link)
        cell.linkImage.image = presenter.getServiceIcon(link: link).maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray) ?? presenter.getServiceIcon(link: link)
        return cell
    }
}

extension SCEgovServiceLongDescriptionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let egovServices = egovServices else {
            return
        }
        presenter.didSelectLink(link: egovServices[indexPath.row])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let groupName = ""
        let view = UIView()
        let label = UILabel()
        label.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 14.0, maxSize: 24.0)
        label.textColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = groupName
        label.numberOfLines = 0
        view.addSubview(label)

        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 12).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 12).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12).isActive = true

        view.layoutIfNeeded()

        label.accessibilityElementsHidden = true
        view.isAccessibilityElement = true
        view.accessibilityElementsHidden = false
        view.accessibilityLabel = title
        view.accessibilityTraits = .header
        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
}
