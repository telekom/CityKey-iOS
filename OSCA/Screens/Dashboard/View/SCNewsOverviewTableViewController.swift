//
//  SCNewsOverviewTableViewController.swift
//  SmartCity
//
//  Created by Michael on 06.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import Kingfisher

class SCNewsOverviewTableViewController: UITableViewController {
    
    public var presenter: SCNewsOverviewPresenting!

    private var items = [SCBaseComponentItem]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        tableView.prefetchDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.presenter.viewWillAppear()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    return .darkContent
                case .dark:
                    return .lightContent
            @unknown default:
               return .darkContent
           }
        } else {
            return .default
        }
        
    }


    private func setupUI() {
        tableView.estimatedRowHeight = GlobalConstants.kNewsListRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        navigationItem.title = LocalizationKeys.SCNewsOverviewTableViewController.h001HomeTitleNews.localized()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SCNewsOverviewTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NewsOverviewMessageCell", for: indexPath) as! SCNewsOverviewTableViewCell
        
        //adaptive Font Size
        cell.newsCellTitleLabel?.adaptFontSize()
        cell.newsCellLabel?.adaptFontSize()

        let title = items[indexPath.row].itemTitle
        let teaser = items[indexPath.row].itemTeaser
        // Configure the cell...
        cell.newsCellTitleLabel?.text = items[indexPath.row].itemTitle
        cell.newsCellLabel.attributedText = teaser?.applyHyphenation()
        cell.newsCellImageView.image = UIImage(named: items[indexPath.row].itemThumbnailURL!.absoluteUrlString())
        
        cell.newsCellLabel.accessibilityElementsHidden = true
        cell.newsCellTitleLabel.accessibilityElementsHidden = true
        cell.newsCellImageView.accessibilityElementsHidden = true
        
        let accItemString = String(format:LocalizationKeys.SCNewsOverviewTableViewController.AccessibilityTableSelectedCell.localized().replaceStringFormatter(), String(indexPath.row + 1), String(items.count))
        cell.accessibilityTraits = .staticText
        cell.accessibilityHint = LocalizationKeys.SCNewsOverviewTableVC.accessibilityCellDblClickHint.localized()
        cell.accessibilityLabel = accItemString + ", " + (teaser ?? "") + ", " + title
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        cell.isAccessibilityElement = true
        
        cell.newsCellLabel.adjustsFontForContentSizeCategory = true
        cell.newsCellLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .subheadline, size: 17, maxSize: nil)
        cell.newsCellTitleLabel.adjustsFontForContentSizeCategory = true
        cell.newsCellTitleLabel.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 12, maxSize: nil)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = self.items[indexPath.row]
        
        self.presenter.didSelectListItem(item: item)
    }
}

extension SCNewsOverviewTableViewController: UITableViewDataSourcePrefetching {

    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let itemURLs = items.compactMap {
            $0.itemThumbnailURL?.absoluteUrl()
        }

        PrefetchNetworkImages.prefetchImagesFromNetwork(with: itemURLs)
    }
}

extension SCNewsOverviewTableViewController: SCNewsOverviewDisplaying {
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showNavigationBar(_ visible : Bool) {
        self.navigationController?.isNavigationBarHidden = !visible
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.present(viewController, animated: true)
    }

    func updateNews(with dataItems: [SCBaseComponentItem]) {
        self.items = dataItems
        self.tableView.reloadData()
    }
}
