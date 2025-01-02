//
//  SCEgovServiceLongDescriptionViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 29/10/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

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
