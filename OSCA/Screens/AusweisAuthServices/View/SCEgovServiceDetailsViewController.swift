/*
Created by Bharat Jagtap on 20/04/21.
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
import Kingfisher
import WebKit

protocol SCEgovServiceDetailsDisplay: SCDisplaying, AnyObject {

    func displayGroups(_ groups: [SCModelEgovGroup] )
    func pushViewController(_ viewController: UIViewController)
    func displayLoadingIndicator()
    func hideLoadingIndicator()
    func displayErrorFailedLoadingGroups()
    func displayErrorZeroGroups()
}

// MARK: - SCEgovServiceDetailsViewController
class SCEgovServiceDetailsViewController: UIViewController {

    var presenter: SCEgovServiceDetailsPresenting!
    @IBOutlet weak var headerImageView: UIImageView!

    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var webViewContainerHeightConstaint: NSLayoutConstraint!
    // @IBOutlet weak var headingLabel : UILabel!
    // @IBOutlet weak var headerTextLabel : UILabel!
//    @IBOutlet weak var headerTextView : UITextView!

    @IBOutlet weak var detailLinkContainer: UIView!
    @IBOutlet weak var detailLinkLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollContentView: UIView!

    @IBOutlet weak var searchPlaceholderView: UIView!
    var searchBar: UISearchBar!
    var searchBarContainer: UIView!
    var isSearchBarFixedToTop = false
    var initialSearchContainerY: CGFloat = 0.0
    private let searchNavigationTransCoordinator = SCEgovSearchNavigationTransitionCoordinator()

    private var groups: [SCModelEgovGroup] = [SCModelEgovGroup]()

    // number of cells per row for portraint and landscape
    private var numberOfCellsPerRow: CGFloat = 2

    private var webView: WKWebView = {
        let configuration = webViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    var webviewHeightConstraint: NSLayoutConstraint?

    static func webViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = userContentController()
        return configuration
    }

    static private func userContentController() -> WKUserContentController {
        let controller = WKUserContentController()
        controller.addUserScript(viewPortScript())
        controller.addUserScript(appearanceScript())
        return controller
    }

    static private func appearanceScript() -> WKUserScript {
        let appearance = """
                        var style = document.createElement('style');
                        style.textContent = '* { background-color: \(UIColor(named: "CLR_WEB_VIEW_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; }';
                        document.head.appendChild(style);
                """
        return WKUserScript(source: appearance, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
    }

    static private func viewPortScript() -> WKUserScript {
        let viewPortScript = """
            var meta = document.createElement('meta');
            meta.setAttribute('name', 'viewport');
            meta.setAttribute('content', 'width=\(UIScreen.main.bounds.size.width - 36.0)');
            meta.setAttribute('initial-scale', '1.0');
            meta.setAttribute('maximum-scale', '1.0');
            meta.setAttribute('minimum-scale', '1.0');
            document.getElementsByTagName('head')[0].appendChild(meta);
        """
        return WKUserScript(source: viewPortScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter.setDisplay(self)
        setupWebView()
        setupUI()
        setupAccessibility()
        self.presenter.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = nil
        refreshNavigationBarStyle()
    }

    @objc func handleDynamicTypeChange(notification: NSNotification) {
        setupUI()
    }

    func setupUI() {

        setupHelpDetailLinkContainer()
        setupSearchBar()

        self.scrollView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        updateCellsPerRow()
        reloadCategories()

        self.title = ""
        self.navigationItem.title = presenter.getServiceTitle()
        self.detailLinkLabel.text = presenter.getBadgeDescriptionText() ?? "egovs_001_details_info_btn".localized()

//        headerTextView.layoutManager.hyphenationFactor = 1.0
//        self.headerTextView.attributedText = presenter.getServiceDetails()
//        self.headerTextView.isScrollEnabled = false
//        self.headerTextView.isEditable = false

        SCImageLoader.sharedInstance.getImage(with: presenter.getServiceImage()!) { [weak self] image, error in
            self?.headerImageView.image = image
        }

        detailLinkLabel.adjustsFontForContentSizeCategory = true
        detailLinkLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .subheadline, 
                                                                      size: 15,
                                                                      maxSize: nil)
        loadWebView(with: presenter.getServiceDetails())
        self.view.setNeedsUpdateConstraints()

    }

    private func loadWebView(with content: String?) {
        guard let content = content else { return }
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = "<span style=\"font-family:-apple-system; font-size: \(fontSize); color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>"
        webView.loadHTMLString(fontSetting + content, baseURL: nil)
    }

    private func setupWebView() {
        webViewContainer.addSubview(webView)
        webView.navigationDelegate = self
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.leadingAnchor.constraint(equalTo: webViewContainer.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: webViewContainer.trailingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: 0).isActive = true
        webviewHeightConstraint = webView.heightAnchor.constraint(equalToConstant: 53)
        webviewHeightConstraint?.isActive = true
    }

    private func setupHelpDetailLinkContainer() {
        let helpDetailsLinkTapGesture = UITapGestureRecognizer(target: self, action: #selector(SCEgovServiceDetailsViewController.detailLinkClicked))
        detailLinkContainer.addGestureRecognizer(helpDetailsLinkTapGesture)
        detailLinkContainer.accessibilityTraits = .button
        detailLinkContainer.accessibilityHint = LocalizationKeys.Accessibility.cellDblTapHint.localized()
        detailLinkContainer.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    func setupSearchBar() {

        searchPlaceholderView.backgroundColor = UIColor.clear
        searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "egov_search_hint".localized()
        searchBar.delegate = self

        searchBarContainer = UIView()
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            searchBarContainer.backgroundColor = UIColor.systemBackground
        } else {
            searchBarContainer.backgroundColor = UIColor.clearBackground
        }

        let topC = NSLayoutConstraint(item: searchBar!, attribute: .top,
                                      relatedBy: .equal, toItem: searchBarContainer,
                                      attribute: .top, multiplier: 1.0, constant: 16)

        let leadC = NSLayoutConstraint(item: searchBar!, attribute: .leading,
                                       relatedBy: .equal, toItem: searchBarContainer,
                                       attribute: .leading, multiplier: 1.0, constant: 17)

        let trailC = NSLayoutConstraint(item: searchBar!, attribute: .trailing,
                                        relatedBy: .equal, toItem: searchBarContainer,
                                        attribute: .trailing, multiplier: 1.0, constant: -17)

        let bottomC = NSLayoutConstraint(item: searchBar!, attribute: .bottom,
                                         relatedBy: .equal, toItem: searchBarContainer,
                                         attribute: .bottom, multiplier: 1.0, constant: -16)

        searchBarContainer.addSubview(searchBar)
        searchBarContainer.addConstraint(topC)
        searchBarContainer.addConstraint(leadC)
        searchBarContainer.addConstraint(trailC)
        searchBarContainer.addConstraint(bottomC)
        addSearchbarToScrollView()

        if #available(iOS 13.0, *) {

            searchBar.searchTextField.adjustsFontForContentSizeCategory = true
            searchBar.searchTextField.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 38)

        }
        /*
        if let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            
            textFieldInsideUISearchBar.adjustsFontForContentSizeCategory = true
            textFieldInsideUISearchBar.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 40)
            
            // SearchBar placeholder
            if let labelInsideUISearchBar = textFieldInsideUISearchBar.value(forKey: "placeholderLabel") as? UILabel {
             
                labelInsideUISearchBar.adjustsFontForContentSizeCategory = true
                labelInsideUISearchBar.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 17, maxSize: (UIScreen.main.bounds.size.width) == 320 ? 17 : 40)
            }
        }
         */

    }

    func setupAccessibility() {

        headerImageView.accessibilityIdentifier = "headerImageView"

//        headerTextView.accessibilityIdentifier = "headerTextView"
//        headerTextView.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        detailLinkLabel.isAccessibilityElement = false
        detailLinkContainer.isAccessibilityElement = true
        detailLinkContainer.accessibilityIdentifier = "detailLink"
        detailLinkContainer.accessibilityLabel = detailLinkLabel.text
        detailLinkContainer.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        detailLinkLabel.accessibilityTraits = .link

        searchBar.accessibilityIdentifier = "searchBar"
        searchBar.accessibilityLabel = ""
        searchBar.accessibilityLanguage = SCUtilities.preferredContentLanguage()

    }

    @objc func detailLinkClicked() {

        self.presenter.didClickHelpMoreInfoButton()
    }

    func reloadCategories() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            let height = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            self.collectionViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {

                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
                loadWebView(with: presenter.getServiceDetails())
            }
        }
    }

    func updateCellsPerRow() {
        let orientation = UIDevice.current.orientation
        // Set the number of cells per row based on the orientation.
        switch orientation {
        case .landscapeLeft,
             .landscapeRight:
            numberOfCellsPerRow = 4
        default:
            numberOfCellsPerRow = 2
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        // Handle the device orientation change.
        coordinator.animate(alongsideTransition: { (_) in
            // Update the number of cells per row when the orientation changes.
            self.updateCellsPerRow()
            self.reloadCategories()
        }, completion: nil)
    }

}

// MARK: - SCEgovServiceCollectionHeaderView

class SCEgovServiceCollectionHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
}

// MARK: - UICollectionViewDataSource

extension SCEgovServiceDetailsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.groups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SCEgovCategoryCell", for: indexPath) as! SCEgovCategoryCell
        let group = self.groups[indexPath.row]
        SCImageLoader.sharedInstance.getImage(with: SCImageURL(urlString: group.groupIcon,
                                                               persistence: false),
                                              completion: { image, error  in
            cell.imageView.image = image
        })
        cell.titleLabel.text = group.groupName

        cell.titleLabel.isAccessibilityElement = false
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = group.groupName
        cell.accessibilityTraits = .button
        cell.accessibilityHint = LocalizationKeys.Accessibility.cellDblTapHint.localized()
        cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        cell.layoutIfNeeded()
        return cell
    }

}

// MARK: - UICollectionViewDelegate

extension SCEgovServiceDetailsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.presenter.didSelectGroup( self.groups[indexPath.row] )
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: "SCEgovServiceCollectionHeaderView",
                                                                               for: indexPath) as? SCEgovServiceCollectionHeaderView {

            sectionHeader.titleLabel.text = "egovs_001_details_categories_headline".localized()

            sectionHeader.titleLabel.adjustsFontForContentSizeCategory = true
            sectionHeader.titleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .callout, size: 16, maxSize: 32)
            sectionHeader.titleLabel.accessibilityTraits = .header
            let headerTitle = "egovs_001_details_categories_headline".localized()
            sectionHeader.titleLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 3))" + headerTitle
            return sectionHeader
        }
        return UICollectionReusableView()
    }

}

// MARK: - UICollectionViewDelegate

extension SCEgovServiceDetailsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfCellsPerRow))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfCellsPerRow))

        return CGSize(width: size, height: UIDevice.current.orientation.isLandscape ? (size + 15) : size)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 3, bottom: 0, right: 3)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: self.collectionView.bounds.width, height: 45)
    }
}

// MARK: - SCEgovServiceDetailsDisplay

extension SCEgovServiceDetailsViewController: SCEgovServiceDetailsDisplay {

    func displayGroups(_ groups: [SCModelEgovGroup] ) {

        self.groups = groups
        reloadCategories()
    }

    func pushViewController(_ viewController: UIViewController) {

        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLoadingIndicator() {

        showActivityOverlay(on: self.view)
    }

    func hideLoadingIndicator() {

        hideOverlay(on: self.view)
    }

    func displayErrorFailedLoadingGroups() {

        showText(on: self.view, text: "poi_002_error_text".localized(), title: "",
                 textAlignment: .center, btnTitle: "e_002_page_load_retry".localized(),
                 btnImage: UIImage(named: "egov_browser_reload")!,
                 btnColor: UIColor.systemBlue, btnAction: {

            self.presenter.loadGroups()

        }, backColor: UIColor.clearBackground)

    }

    func displayErrorZeroGroups() {

        showText(on: self.view, text: "poi_002_error_text".localized(), title: "",
                 textAlignment: .center, btnTitle: "e_002_page_load_retry".localized(),
                 btnImage: UIImage(named: "egov_browser_reload")!,
                 btnColor: UIColor.systemBlue, btnAction: {

            self.presenter.loadGroups()

        }, backColor: UIColor.clearBackground)

    }

}

// MARK: - UIScrollViewDelegate

extension SCEgovServiceDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var barRect = CGRect.zero
        let rectInView = scrollContentView.convert(self.searchPlaceholderView.frame, to: self.view)
        if let navigationController = navigationController {
            barRect = self.view.convert(navigationController.navigationBar.frame, to: self.view)
        }

        if rectInView.origin.y < ( barRect.origin.y + barRect.size.height ) {
            if !isSearchBarFixedToTop {
                isSearchBarFixedToTop = true
                stickSearchbarToTop()
            }

        } else {

            if isSearchBarFixedToTop {
                isSearchBarFixedToTop = false
                addSearchbarToScrollView()
            }
        }

    }

    func stickSearchbarToTop() {

        searchBarContainer.removeFromSuperview()

        let barRect = self.view.convert(self.navigationController!.navigationBar.frame, to: self.view)

        let topC = NSLayoutConstraint(item: searchBarContainer!, attribute: .top,
                                      relatedBy: .equal, toItem: self.view,
                                      attribute: .top, multiplier: 1.0,
                                      constant: barRect.origin.y + barRect.size.height )

        let leadC = NSLayoutConstraint(item: searchBarContainer!, attribute: .leading,
                                       relatedBy: .equal, toItem: self.view, attribute: .leading,
                                       multiplier: 1.0, constant: 0)

        let trailC = NSLayoutConstraint(item: searchBarContainer!, attribute: .trailing,
                                        relatedBy: .equal, toItem: self.view, attribute: .trailing,
                                        multiplier: 1.0, constant: 0)

        let heightC = NSLayoutConstraint(item: searchBarContainer!, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1.0, constant: 70)

        self.view.insertSubview(searchBarContainer, aboveSubview: self.scrollContentView)
        self.view.addConstraint(topC)
        self.view.addConstraint(leadC)
        self.view.addConstraint(trailC)
        searchBarContainer.addConstraint(heightC)
        self.view.bringSubviewToFront(searchBarContainer)

        addShaddowToSearchContainer()
    }

    func addSearchbarToScrollView() {

        searchBarContainer.removeFromSuperview()

        let topC = NSLayoutConstraint(item: searchBarContainer!, attribute: .top,
                                      relatedBy: .equal, toItem: searchPlaceholderView,
                                      attribute: .top, multiplier: 1.0, constant: 0)

        let leadC = NSLayoutConstraint(item: searchBarContainer!, attribute: .leading,
                                       relatedBy: .equal, toItem: searchPlaceholderView,
                                       attribute: .leading, multiplier: 1.0, constant: 0)

        let trailC = NSLayoutConstraint(item: searchBarContainer!, attribute: .trailing,
                                        relatedBy: .equal, toItem: searchPlaceholderView,
                                        attribute: .trailing, multiplier: 1.0, constant: 0)

        let bottomC = NSLayoutConstraint(item: searchBarContainer!, attribute: .bottom,
                                         relatedBy: .equal, toItem: searchPlaceholderView,
                                         attribute: .bottom, multiplier: 1.0, constant: 0)

        searchPlaceholderView.addSubview(searchBarContainer)
        searchPlaceholderView.addConstraint(topC)
        searchPlaceholderView.addConstraint(leadC)
        searchPlaceholderView.addConstraint(trailC)
        searchPlaceholderView.addConstraint(bottomC)

        removeShaddowFromSearchContainer()

    }

    func addShaddowToSearchContainer() {

        searchBarContainer.layer.masksToBounds = false
        searchBarContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        searchBarContainer.layer.shadowRadius = 2
        searchBarContainer.layer.shadowOpacity = 0.5
        searchBarContainer.layer.shadowColor = UIColor.gray.cgColor

    }

    func removeShaddowFromSearchContainer() {

        searchBarContainer.layer.masksToBounds = true
        searchBarContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        searchBarContainer.layer.shadowRadius = 0
        searchBarContainer.layer.shadowOpacity = 0.0

    }

}

// MARK: - UISearchBarDelegate

extension SCEgovServiceDetailsViewController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.navigationController?.delegate = searchNavigationTransCoordinator
        presenter.didTapOnSearch()
        return false
    }
}

// MARK: - SCEgovSearchNavigationTransitionOriginator

extension SCEgovServiceDetailsViewController: SCEgovSearchNavigationTransitionOriginator {
    var fromAnimatedSubviews: [UIView] { return [searchBarContainer] }
}

// MARK: - SCEgovSearchNavigationTransitionDestination

extension SCEgovServiceDetailsViewController: SCEgovSearchNavigationTransitionDestination {
    var toAnimatedSubviews: [UIView] { return [searchBarContainer] }
    var viewsToBeHiddenDuringTransition: [UIView]? { return nil }
}

extension SCEgovServiceDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                var style = document.createElement('style');
                style.textContent = '* { background-color:
                \(UIColor(named: "CLR_WEB_VIEW_BCKGRND")!.hexDecimalString) !important;
                color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; }';
                document.head.appendChild(style);
                """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
            DispatchQueue.main.async { [weak self] in
                self?.webViewContainerHeightConstaint?.constant = height as! CGFloat
                self?.webviewHeightConstraint?.constant = height as! CGFloat
            }
        })
    }
}
