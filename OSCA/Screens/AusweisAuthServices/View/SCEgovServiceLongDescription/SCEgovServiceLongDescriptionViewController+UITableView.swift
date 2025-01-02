//
//  SCEgovServiceLongDescriptionViewController+UITableView.swift
//  OSCA
//
//  Created by Bhaskar N S on 06/05/24.
//  Copyright © 2024 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
