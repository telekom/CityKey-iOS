//
//  SCEgovServicesListViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 21/04/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
