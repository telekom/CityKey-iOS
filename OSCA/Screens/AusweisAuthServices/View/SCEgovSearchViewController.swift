//
//  SCEgovSearchViewController.swift
//  OSCA
//
//  Created by Bharat Jagtap on 18/10/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

// MARK: - SCEgovSearchDisplay

protocol SCEgovSearchDisplay : SCDisplaying, AnyObject {
    
    func pushViewController(_ viewController : UIViewController)
    func displayLoadingIndicator()
    func hideLoadingIndicator()
    func displayErrorZeroSearchResult(message: String)
    func displayErrorZeroHistoryTerms(message: String)
    func showSearchHistoryTerms(terms : [String] )
    func showSearchResult(result : [SCModelEgovService])
}

// MARK: - SCEgovSearchViewController

class SCEgovSearchViewController: UIViewController {
    
    var presenter : SCEgovSearchPresenting!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarContainer: UIView!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var headerLabelContainer : UIView!
    @IBOutlet weak var headerLabelContainerHeightConstraint : NSLayoutConstraint!
    @IBOutlet weak var errorLabel : UILabel!


    private var historyTermsDataSourceDelegate : SCEgovHistoryTermsDataSourceDelegate!
    private var searchResultDataSourceDelegate : SCEgovSearchResultDataSourceDelegate!
    private let searchNavigationTransCoordinator = SCEgovSearchNavigationTransitionCoordinator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setDisplay(self)
        
        historyTermsDataSourceDelegate = SCEgovHistoryTermsDataSourceDelegate()
        searchResultDataSourceDelegate = SCEgovSearchResultDataSourceDelegate()
        
        
        historyTermsDataSourceDelegate.onCellSelectionHandler = { [weak self] (index, term) in
            self?.searchBar.text = term
            self?.presenter.searchTextChanged(text: term)
        }
        
        searchResultDataSourceDelegate.onCellSelectionHandler = { [weak self] (index, service) in
            self?.presenter.didSelectResultItemAtIndex(index: index, object: service)
        }
        
        historyTermsDataSourceDelegate.onTableViewDidScroll = { [weak self] in
            self?.searchBar.resignFirstResponder()
        }
        
        searchResultDataSourceDelegate.onTableViewDidScroll = { [weak self] in
            self?.searchBar.resignFirstResponder()
        }
        
        searchResultDataSourceDelegate.customiseCell = { [weak self] (model, cell) in
            
            cell.titleLabel.text = self?.presenter.getServiceTitle(service: model)
            cell.typeLabel.text = self?.presenter.getServiceLinkTitle(service: model)
            cell.typeImageView.image = self?.presenter.getServiceIcon(service: model).maskWithColor(color: UIColor(named: "CLR_ICON_TINT_BLACK") ?? UIColor.darkGray )
            cell.descLabel.attributedText = self?.presenter.getServiceDescription(service: model).applyHyphenation()
        }
        
        setupUI()
        setupAccessibility()
        presenter.viewDidLoad()
    }
    
    func setupUI() {
        
        self.navigationItem.backButtonTitle = "navigation_bar_back".localized()
        self.navigationItem.backBarButtonItem?.accessibilityLabel = "navigation_bar_back".localized()
        self.navigationItem.title = "egov_search_hint".localized() //presenter.getServiceTitle()
        
        searchBar.placeholder = "egov_search_hint".localized()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        searchResultTableView.register(UINib(nibName: "SCEgovServiceCell", bundle: nil), forCellReuseIdentifier: "SCEgovServiceCell")
        searchResultTableView.register(UITableViewCell.self, forCellReuseIdentifier: SCEgovHistoryTermsDataSourceDelegate.cellReuseIdentifier)
        searchResultTableView.rowHeight = UITableView.automaticDimension
        searchResultTableView.dataSource = historyTermsDataSourceDelegate
        searchResultTableView.delegate = historyTermsDataSourceDelegate
        
        headerLabelContainer.backgroundColor = UIColor.clearBackground
        
        // TableView Header
        headerLabel.textColor =  UIColor.labelTextBlackCLR
        headerLabel.adjustsFontForContentSizeCategory = true
        headerLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17, maxSize: nil)
        headerLabel.text = "egov_search_last_searches_label".localized()
        
        // Error Label
        errorLabel.textColor = UIColor.labelTextBlackCLR
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: nil)
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.adjustsFontForContentSizeCategory = true
            searchBar.searchTextField.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 38)
        }
        
        // SearchBar TextField
//        if let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField {
//
//            textFieldInsideUISearchBar.adjustsFontForContentSizeCategory = true
//            textFieldInsideUISearchBar.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 38)
//
//            // SearchBar placeholder
//            if let labelInsideUISearchBar = textFieldInsideUISearchBar.value(forKey: "placeholderLabel") as? UILabel {
//
//                labelInsideUISearchBar.adjustsFontForContentSizeCategory = true
//                labelInsideUISearchBar.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 38)
//            }
//        }
        
        
      
        
    }
    
    func setupAccessibility() {
        
        headerLabel.accessibilityLabel = ""
        headerLabel.accessibilityIdentifier = "headerLabel"
        headerLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        
        searchBar.accessibilityLabel = ""
        searchBar.accessibilityIdentifier = "searchBar"
        searchBar.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                searchResultTableView.reloadData()
            }
        }
    }
    
    
    @objc func backButtonClicked(sender: AnyObject) {
        self.navigationController?.delegate = searchNavigationTransCoordinator
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = searchNavigationTransCoordinator
        refreshNavigationBarStyle()
    }
    
}

// MARK: - SCEgovSearchNavigationTransitionOriginator

extension SCEgovSearchViewController: SCEgovSearchNavigationTransitionOriginator {
    var fromAnimatedSubviews: [UIView] { return [searchBarContainer] }
}

// MARK: - SCEgovSearchNavigationTransitionDestination

extension SCEgovSearchViewController: SCEgovSearchNavigationTransitionDestination {
    
    var toAnimatedSubviews: [UIView] { return [searchBarContainer] }
    
    var viewsToBeHiddenDuringTransition: [UIView]? {
        return [self.searchBarContainer, self.headerLabelContainer, self.searchResultTableView, self.errorLabel]
    }
}

// MARK: - UISearchBarDelegate

extension SCEgovSearchViewController : UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.presenter.searchTextChanged(text: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}

// MARK: - SCEgovSearchDisplay

extension SCEgovSearchViewController : SCEgovSearchDisplay {
    
    func pushViewController(_ viewController : UIViewController) {
        
        self.navigationController?.delegate = nil
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func displayLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func displayErrorZeroSearchResult(message: String){

        self.headerLabel.text = "egov_search_results_label\n".localized()

        headerLabelContainerHeightConstraint.constant = 44
        headerLabel.isHidden = false
        searchResultTableView.isHidden = true
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    func displayErrorZeroHistoryTerms(message: String) {

        self.headerLabel.text = "egov_search_last_searches_label".localized()

        headerLabelContainerHeightConstraint.constant = 0
        headerLabel.isHidden = true
        searchResultTableView.isHidden = true
        errorLabel.isHidden = false
        errorLabel.text = message
        
    }
    
    func showSearchHistoryTerms(terms : [String]){
        
        headerLabelContainerHeightConstraint.constant = 44
        headerLabel.isHidden = false
        errorLabel.text = ""
        errorLabel.isHidden = true
        searchResultTableView.isHidden = false
        
        historyTermsDataSourceDelegate.terms = terms
        searchResultTableView.delegate = historyTermsDataSourceDelegate
        searchResultTableView.dataSource = historyTermsDataSourceDelegate
        searchResultTableView.reloadData()
        self.headerLabel.text = "egov_search_last_searches_label".localized()
    }
    
    func showSearchResult(result : [SCModelEgovService]){
        
        headerLabelContainerHeightConstraint.constant = 44
        headerLabel.isHidden = false
        errorLabel.text = ""
        errorLabel.isHidden = true
        searchResultTableView.isHidden = false
        
        searchResultDataSourceDelegate.serviceList = result
        searchResultTableView.delegate = searchResultDataSourceDelegate
        searchResultTableView.dataSource = searchResultDataSourceDelegate
        searchResultTableView.reloadData()
        self.headerLabel.text = "egov_search_results_label\n".localized()
    }
    
    
}

// MARK: - SCEgovHistoryTermsDataSourceDelegate

class SCEgovHistoryTermsDataSourceDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    static let cellReuseIdentifier = "UITableViewCellStyle.default"
    var terms : [String]?
    var onCellSelectionHandler : ((_ index: Int, _ term : String) -> Void)?
    var onTableViewDidScroll : (() -> ())?

    override init() {
        super.init()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return terms?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SCEgovHistoryTermsDataSourceDelegate.cellReuseIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0 
        cell.textLabel?.text = terms?[indexPath.row]
        cell.backgroundColor = UIColor.clearBackground
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let term = terms?[indexPath.row] {
            onCellSelectionHandler?(indexPath.row, term)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onTableViewDidScroll?()
    }
}

// MARK: - SCEgovSearchResultDataSourceDelegate

class SCEgovSearchResultDataSourceDelegate : NSObject, UITableViewDataSource, UITableViewDelegate {
    
    static let cellReuseIdentifier = "SCEgovServiceCell"
    var serviceList : [SCModelEgovService]?
    var onCellSelectionHandler : ((_ index: Int, _ service : SCModelEgovService) -> Void )?
    var onTableViewDidScroll : (() -> ())?
    var customiseCell : ((_ service: SCModelEgovService, _ cell: SCEgovServiceCell) -> ())?

    override init() {
        super.init()
        
    }
    
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
            onCellSelectionHandler?(indexPath.section, service)
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
            
            cell.accessibilityTraits = .button
            self.customiseCell?(model, cell)
            
        } else {
        
            cell.titleLabel.text = ""
            cell.typeLabel.text = ""
            cell.descLabel.text = ""
            cell.typeImageView.image = nil
        }
        cell.backgroundColor = UIColor.clearBackground
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onTableViewDidScroll?()
    }
    
}
