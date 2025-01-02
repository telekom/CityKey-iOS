//
//  SCBasicPOIGuideDetailViewController.swift
//  OSCA
//
//  Created by Harshada Deshmukh on 23/03/21.
//  Copyright © 2021 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit

class SCBasicPOIGuideDetailViewController: UIViewController {

    public var presenter: SCBasicPOIGuideDetailPresenting!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageCategory: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
//    @IBOutlet weak var descriptionTxtV: UITextView!
    @IBOutlet weak var openHoursTxtV: UITextView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var openHoursLbl: UILabel!
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var descriptionStack: UIStackView!
    @IBOutlet weak var openHoursStack: UIStackView!
    @IBOutlet weak var websiteStack: UIStackView!
    @IBOutlet weak var topSpaceFromOpenHoursConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceFromDescConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceFromWebsiteConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceFromMapConstraint: NSLayoutConstraint!
    @IBOutlet weak var descHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var openHoursHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapOnInfolbl: UILabel!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var descriptionTxtV: SCWebView!
    @IBOutlet weak var descriptionTxtVHeight: NSLayoutConstraint!
    
    var mapViewController : SCMapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let insets = UIEdgeInsets(top: 0, left: -7, bottom: 0, right: 7) // Adjust as needed
        descriptionTxtV.webView.scrollView.contentInset = insets
        descriptionTxtV.webView.scrollView.scrollIndicatorInsets = insets
        descriptionTxtV.webView.navigationDelegate = self
        self.shouldNavBarTransparent = false
        handleDynamicTypeChange()
        self.adaptFontSizes()
        self.setDescriptionTexts()

        setupMapView()
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        let websiteTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.websiteLinkWasPressed))
        self.websiteLabel.addGestureRecognizer(websiteTapGesture)
        registerForNotifications()
    }
    
    @objc fileprivate func handleDynamicTypeChange() {
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        openHoursLbl.adjustsFontForContentSizeCategory = true
        openHoursLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        openHoursTxtV.adjustsFontForContentSizeCategory = true
        openHoursTxtV.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        descriptionLbl.adjustsFontForContentSizeCategory = true
        descriptionLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
//        descriptionTxtV.adjustsFontForContentSizeCategory = true
//        descriptionTxtV.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        websiteLbl.adjustsFontForContentSizeCategory = true
        websiteLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        websiteLabel.adjustsFontForContentSizeCategory = true
        websiteLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        addressLbl.adjustsFontForContentSizeCategory = true
        addressLbl.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 15.0, maxSize: 24.0)
        tapOnInfolbl.adjustsFontForContentSizeCategory = true
        tapOnInfolbl.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14.0, maxSize: 22.0)
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
        SCDataUIEvents.registerNotifications(for: self,
                                             on: UIContentSizeCategory.didChangeNotification,
                                             with: #selector(handleDynamicTypeChange))
    }
    
    private func setupMapView() {
        mapViewController?.delegate = self
        mapViewController?.mapViewContainer.frame = mapViewContainer.bounds
    }
    
    @objc func willEnterForeground() {
        self.presenter.reloadDetailPageContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
    }

    /**
     *
     * Method to get referenced of the embedded viewController
     *
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
            
        case let mapViewController as SCMapViewController:
            self.mapViewController = mapViewController
            
        default:
            break
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                if let imageCategory = self.imageCategory?.image{
                    self.imageCategory?.image = imageCategory.maskWithColor(color: kColor_cityColor)
                }
            }
        }
    }
    
    private func setDescriptionTexts() {
        self.addressLbl.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001AddressLabel.localized()
        self.openHoursLbl.text = LocalizationKeys.SCBasicPOIGuideListMapFilterViewController.poi001OpeningHoursLabel.localized()
        self.descriptionLbl.text = LocalizationKeys.SCBasicPOIGuideDetailViewController.poi003DescriptionLabel.localized()
        self.websiteLbl.text = LocalizationKeys.SCBasicPOIGuideDetailViewController.poi003WebsiteLabel.localized()
        self.tapOnInfolbl.text = LocalizationKeys.SCBasicPOIGuideDetailViewController.e006EventTapOnMapHint.localized()
    }
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.categoryLabel.accessibilityIdentifier = "lbl_category"
        self.subtitleLabel.accessibilityIdentifier = "lbl_subtitle"
        self.imageCategory.accessibilityIdentifier = "img_category"
        self.descriptionTxtV.accessibilityIdentifier = "lbl_description"
        self.openHoursTxtV.accessibilityIdentifier = "lbl_open_hours"
        self.websiteLabel.accessibilityIdentifier = "lbl_website"
        self.descriptionLbl.accessibilityIdentifier = "lbl_description_heading"
        self.openHoursLbl.accessibilityIdentifier = "lbl_open_hours_heading"
        self.websiteLbl.accessibilityIdentifier = "lbl_website_heading"
        self.addressLbl.accessibilityIdentifier = "lbl_address_heading"
        self.mapViewController?.view.accessibilityIdentifier = "view_map"
        self.tapOnInfolbl.accessibilityIdentifier = "lbl_taponinfo"

    }

    private func setupAccessibility(){
        self.navigationItem.backButtonTitle?.accessibilityTraits = .button
        self.navigationItem.backButtonTitle?.accessibilityLabel = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationItem.backButtonTitle?.accessibilityLanguage = SCUtilities.preferredContentLanguage()

        self.accessibilityTraits = .staticText
        let category = (self.categoryLabel.text ?? "") + ", "
        let subtitle = !self.subtitleLabel.text!.isSpaceOrEmpty() ? (self.subtitleLabel.text ?? "") + ", " : ""
//        let description = !self.descriptionTxtV.text!.isSpaceOrEmpty() ? (self.descriptionLbl.text ?? "") + ", " + (self.descriptionTxtV.text ?? "") + ", " : ""
        let openHours = !self.openHoursTxtV.text!.isSpaceOrEmpty() ? (self.openHoursLbl.text ?? "") + ", " + (self.openHoursTxtV.text ?? "") + ", " : ""
        let website = !self.websiteLabel.text!.isSpaceOrEmpty() ? (self.websiteLbl.text ?? "") + ", " + (self.websiteLabel.text ?? "") + ", " : ""
        let address = !self.addressLbl.isHidden ? (self.addressLbl.text ?? "") + ", " + (self.mapViewController?.locationlbl.text ?? "") + ", " : ""
        self.accessibilityLabel = category + subtitle + description + openHours + website + address
        self.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.isAccessibilityElement = true
    }

    private func adaptFontSizes() {
        self.categoryLabel.adaptFontSize()
        self.subtitleLabel.adaptFontSize()
//        self.descriptionTxtV.adaptFontSize()
        self.openHoursTxtV.adaptFontSize()
        self.websiteLabel.adaptFontSize()
        self.descriptionLbl.adaptFontSize()
        self.openHoursLbl.adaptFontSize()
        self.websiteLbl.adaptFontSize()
        self.addressLbl.adaptFontSize()
        self.tapOnInfolbl.adaptFontSize()
    }
    
    @objc func websiteLinkWasPressed(gesture: UITapGestureRecognizer) {
                
        var websiteLink = self.websiteLabel.text
        if !(websiteLink!.starts(with: "http://")) && !websiteLink!.starts(with: "https://") {
            websiteLink = "http://\(websiteLink!)"
        }
        
        if websiteLink != nil{

            let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = detector.matches(in: websiteLink!, options: [], range: NSRange(location: 0, length: websiteLink!.utf16.count))
            
            let tapLocation = gesture.location(in: websiteLabel)

            let indexOfCharacter = gesture.didTapAttributedTextInLabel(label: websiteLabel!, tapLocation: tapLocation)

            for match in matches {

                if NSLocationInRange(indexOfCharacter, match.range) {

                    //open selected URL
                    let link = websiteLink! as NSString
                    let linkStr = link.substring(with: match.range)
                    if let urlToOpen = URL(string: linkStr), UIApplication.shared.canOpenURL(urlToOpen) {
                        SCInternalBrowser.showURL(urlToOpen, withBrowserType: .safari)
                    }
                    break;
                }else {
                    print("Tapped none")
                }
            }
        }
    }
}

extension SCBasicPOIGuideDetailViewController : SCMapViewDelegate {
    func mapWasTapped(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        self.presenter.mapViewWasPressed(latitude: latitude, longitude: longitude, zoomFactor: zoomFactor, address: address)
    }
    
    func directionsBtnWasPressed(latitude : Double, longitude : Double, address: String){
        self.presenter.directionsButtonWasPressed(latitude: latitude, longitude: longitude, address: address)
    }

}

extension SCBasicPOIGuideDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let appearance = """
                   var style = document.createElement('style');
                   style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; }';
                   document.head.appendChild(style);
           """
        webView.evaluateJavaScript(appearance, completionHandler: nil)
        let customCss = """
        var style = document.createElement('style');
        style.textContent = '* { width: 99%; overflow-x: hidden; -webkit-hyphens: auto; hyphens: auto; }';
        document.head.appendChild(style);
        """
        webView.evaluateJavaScript(customCss, completionHandler: nil)
        hightlightURLs(webView)
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
            DispatchQueue.main.async { [weak self] in
                self?.descriptionTxtVHeight?.constant = height as! CGFloat
            }
        })
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url {
            if url.scheme == "mailto" || url.scheme == "tel" {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
                }
            }
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
//    var phones = document.body.innerHTML.match(/\\d{4,}\\/\\s?\\d{4,}/);
//    var phones = document.body.innerHTML.match(/(?:(?:\\d{5,}|\\d{6,})\\/?\\s?\\d{5,})/);
    fileprivate func hightlightURLs(_ webView: WKWebView) {
        // Inject JavaScript to modify the HTML content and highlight URLs
        let javascript = """
        var urls = document.body.innerText.match(/(https?:\\/\\/[^\\s]+)/g);
        var emails = document.body.innerHTML.match(/\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b/g) || [];
        var phones = document.body.innerHTML.match(/(?:\\d{5}\\s\\d{6}|0?\\d{4,5}[\\/\\s]?\\d{6,7}|\\d{4,}\\s?\\/?\\s?\\d{3}\\s?\\d{3}|[1-9]\\d{8,})/);
        
        
        if (urls !== null) {
            urls.forEach(function(url) {
                var replacedHtml = document.body.innerHTML.replace(url, '<a href="' + url + '" style="color: \(kColor_cityColor.hexDecimalString);">' + url + '</a>');
                document.body.innerHTML = replacedHtml;
            });
        }
        
        if (emails !== null) {
                emails.forEach(function(email) {
                    var replacedHtml = document.body.innerHTML.replace(email, '<a href="mailto:' + email + '" style="color: \(kColor_cityColor.hexDecimalString);">' + email + '</a>');
                    document.body.innerHTML = replacedHtml;
                });
            }
        
        if (phones !== null) {
            phones.forEach(function(phone) {
                    var replacedHtml = document.body.innerHTML.replace(phone, '<a href="tel:' + phone + '" style="color: \(kColor_cityColor.hexDecimalString);">' + phone + '</a>');
                document.body.innerHTML = replacedHtml;
            });
        }
        """
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
}
