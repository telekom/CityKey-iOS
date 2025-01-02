//
//  SCEventDetailViewController.swift
//  SmartCity
//
//  Created by Michael on 23.10.19.
//  Copyright © 2019 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit
import WebKit
import MapKit

class SCEventDetailViewController: UIViewController {
    
    public var presenter: SCEventDetailPresenting!
    
    @IBOutlet weak var eventTitleSeperatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoCreditLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    
    @IBOutlet weak var mapHeightConstraint: NSLayoutConstraint!
    //DateBox
    @IBOutlet weak var dateBox: UIView!
    @IBOutlet weak var singleDateTopLbl: UILabel!
    @IBOutlet weak var singleDateBottomLbl: UILabel!
    @IBOutlet weak var firstDateTopLbl: UILabel!
    @IBOutlet weak var firstDateMiddleLbl: UILabel!
    @IBOutlet weak var firstDateBottomLbl: UILabel!
    @IBOutlet weak var secondDateTopLbl: UILabel!
    @IBOutlet weak var secondDateMiddleLbl: UILabel!
    @IBOutlet weak var secondDateBottomLbl: UILabel!
    @IBOutlet weak var firstSecondSep: UILabel!
    
    //Event Time
    @IBOutlet weak var startTimeDescLbl: UILabel!
    @IBOutlet weak var startTimeLbl: UILabel!
    @IBOutlet weak var endTimeDescLbl: UILabel!
    @IBOutlet weak var endTimeLbl: UILabel!
    
    // Btn
    @IBOutlet weak var addToCslLbl: UILabel!
    @IBOutlet weak var addToCslImageView: UIImageView!
    @IBOutlet weak var favoritesLbl: UILabel!
    
    // Description
    @IBOutlet var descShowMoreDetailBottomConstraint: NSLayoutConstraint!
    @IBOutlet var descDetailTopConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var descDetailTextView: UITextView!
    
    @IBOutlet weak var descMoreLinkLbl: UILabel!
    @IBOutlet weak var descMoreSeperator: UIView!
    
    @IBOutlet weak var descPdfTitle: UILabel!
    @IBOutlet weak var descPdfLinkLbl: UILabel!
    
    @IBOutlet weak var descPdfSeperator: UIView!
    
    @IBOutlet weak var favoriteStarImageView: UIImageView!
    @IBOutlet weak var pdfCardView: UIView!
    @IBOutlet weak var eventStatusLabel: UILabelInsets!
    @IBOutlet var favoriteTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var imageViewTapGestureRecognizer: UITapGestureRecognizer!
    
    //Seperators
    @IBOutlet weak var eventTitleBottomSeperator: UIView!
    @IBOutlet weak var dateBoxBottomSeperator: UIView!
    @IBOutlet weak var mapViewBottomSeperator: UIView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint1: NSLayoutConstraint!
    
    @IBOutlet weak var failedImageView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var failedImageViewHeightConstraint: NSLayoutConstraint!
    
    private var mapViewController : SCMapViewController?
    private var descDetailShowAll = false
    private var detailLabelMaxHeight = 100
    private var webview : WKWebView?
    private var moreTextBtnNeeded : Bool = false
    var imageURL : SCImageURL?
    var moreInfoURL: URL?
    
    @IBOutlet weak var tapOnInfolbl: UILabel!
    @IBOutlet weak var tapOnInfolblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descDetailWebView: SCWebView!
    @IBOutlet weak var descWebViewHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var descDetailStackView: UIStackView!
    private var descDetail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shouldNavBarTransparent = false
        
        self.adaptFontSizes()
        
        self.mapViewController?.delegate = self
        
        self.presenter.setDisplay(self)
        self.presenter.viewDidLoad()
        self.favoriteTapGestureRecognizer.addTarget(self, action: #selector(handleFavoriteViewTapped(_:)))
        self.imageViewTapGestureRecognizer.addTarget(self, action: #selector(handleImageViewTapped(_:)))
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        self.handleDynamicTypeChange()
        setupWebView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDynamicTypeChange), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    private func setupWebView() {
        descDetailWebView.webView.navigationDelegate = self
        descDetailWebView.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            self?.presenter.refreshUI()
        }
    }

    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        
        self.navigationItem.title = eventTitleLabel.text
        self.navigationItem.backButtonTitle = LocalizationKeys.Common.navigationBarBack.localized()
        
        photoCreditLabel.adjustsFontForContentSizeCategory = true
        photoCreditLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 13, maxSize: 20)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 12, maxSize: nil)
        eventTitleLabel.adjustsFontForContentSizeCategory = true
        eventTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .title3, size: 24, maxSize: nil)
        
        handleDynamicChangeForDateComponent()
        
        handleDynamicChangeForDescription()
        
        addToCslLbl.adjustsFontForContentSizeCategory = true
        addToCslLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 30)
        favoritesLbl.adjustsFontForContentSizeCategory = true
        favoritesLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 30)
        
        eventStatusLabel.adjustsFontForContentSizeCategory = true
        eventStatusLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .footnote, size: 12, maxSize: 30)
        errorLabel.adjustsFontForContentSizeCategory = true
        errorLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 13, maxSize: nil)
        retryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        retryButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 25)
        tapOnInfolbl.adjustsFontForContentSizeCategory = true
        tapOnInfolbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        
        setEventComponentNoOfLines()
        
    }
    
    func handleDynamicChangeForDescription(){
        descMoreLinkLbl.adjustsFontForContentSizeCategory = true
        descMoreLinkLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: nil)
        descPdfTitle.adjustsFontForContentSizeCategory = true
        descPdfTitle.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 25)
        descPdfLinkLbl.adjustsFontForContentSizeCategory = true
        descPdfLinkLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 14, maxSize: 25)
        loadWebView(with: descDetail)
    }
    
    func handleDynamicChangeForDateComponent(){
        singleDateTopLbl.adjustsFontForContentSizeCategory = true
        singleDateTopLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 25)
        singleDateBottomLbl.adjustsFontForContentSizeCategory = true
        singleDateBottomLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 21, maxSize: 25)
        firstDateTopLbl.adjustsFontForContentSizeCategory = true
        firstDateTopLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 18)
        firstDateMiddleLbl.adjustsFontForContentSizeCategory = true
        firstDateMiddleLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 18)
        firstDateBottomLbl.adjustsFontForContentSizeCategory = true
        firstDateBottomLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 18)
        secondDateTopLbl.adjustsFontForContentSizeCategory = true
        secondDateTopLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 18)
        secondDateMiddleLbl.adjustsFontForContentSizeCategory = true
        secondDateMiddleLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 18)
        secondDateBottomLbl.adjustsFontForContentSizeCategory = true
        secondDateBottomLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 18)
        firstSecondSep.adjustsFontForContentSizeCategory = true
        firstSecondSep.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 12, maxSize: 30)
        startTimeDescLbl.adjustsFontForContentSizeCategory = true
        startTimeDescLbl.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 16, maxSize: 25)
        startTimeLbl.adjustsFontForContentSizeCategory = true
        startTimeLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 16, maxSize: 25)
        endTimeDescLbl.adjustsFontForContentSizeCategory = true
        endTimeDescLbl.font = UIFont.SystemFont.medium.forTextStyle(style: .footnote, size: 16, maxSize: 25)
        endTimeLbl.adjustsFontForContentSizeCategory = true
        endTimeLbl.font = UIFont.SystemFont.regular.forTextStyle(style: .footnote, size: 16, maxSize: 25)
    }
    
    func setEventComponentNoOfLines(){
        photoCreditLabel.numberOfLines = 0
        categoryLabel.numberOfLines = 0
        singleDateTopLbl.numberOfLines = 0
        singleDateBottomLbl.numberOfLines = 0
        firstDateTopLbl.numberOfLines = 0
        firstDateMiddleLbl.numberOfLines = 0
        firstDateBottomLbl.numberOfLines = 0
        secondDateTopLbl.numberOfLines = 0
        secondDateMiddleLbl.numberOfLines = 0
        secondDateBottomLbl.numberOfLines = 0
        firstSecondSep.numberOfLines = 0
        startTimeDescLbl.numberOfLines = 0
        startTimeLbl.numberOfLines = 0
        endTimeDescLbl.numberOfLines = 0
        endTimeLbl.numberOfLines = 0
        addToCslLbl.numberOfLines = 0
        favoritesLbl.numberOfLines = 0
        descPdfTitle.numberOfLines = 0
        eventStatusLabel.numberOfLines = 0
        errorLabel.numberOfLines = 0
        retryButton.titleLabel?.numberOfLines = 0
        tapOnInfolbl.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshNavigationBarStyle()
        // To avoid flickeing issue on google maps for dark mode
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                if let view = mapViewController?.mapViewContainer {
                    self.showActivityOverlay(on: view, hideActivityIndicator: false)
                    SCUtilities.delay(withTime: 0.5) {
                        self.hideOverlay(on: view)
                    }
                }
            }
        }
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
    
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
        self.shareBtn.accessibilityIdentifier = "btn_close"
        self.photoCreditLabel.accessibilityIdentifier = "lbl_photocredit"
        self.categoryLabel.accessibilityIdentifier = "lbl_category"
        self.eventTitleLabel.accessibilityIdentifier = "lbl_title"
        self.dateBox.accessibilityIdentifier = "view_datebox"
        self.singleDateTopLbl.accessibilityIdentifier = "lbl_singledate_top"
        self.singleDateBottomLbl.accessibilityIdentifier = "lbl_singledate_bottom"
        self.firstDateMiddleLbl.accessibilityIdentifier = "lbl_firstdate_middle"
        self.firstDateBottomLbl.accessibilityIdentifier = "lbl_firstdate_bottom"
        self.secondDateMiddleLbl.accessibilityIdentifier = "lbl_seconddate_middle"
        self.secondDateBottomLbl.accessibilityIdentifier = "lbl_seconddate_bottom"
        self.startTimeDescLbl.accessibilityIdentifier = "lbl_starttimedesc"
        self.startTimeLbl.accessibilityIdentifier = "lbl_starttime"
        self.endTimeDescLbl.accessibilityIdentifier = "lbl_endtimedesc"
        self.endTimeLbl.accessibilityIdentifier = "lbl_endtime"
        self.addToCslLbl.accessibilityIdentifier = "lbl_addcalendar"
        self.descMoreLinkLbl.accessibilityIdentifier = "lbl_morelink"
        self.descPdfTitle.accessibilityIdentifier = "lbl_pdftitle"
        self.descPdfLinkLbl.accessibilityIdentifier = "lbl_pdflink"
        self.mapViewController?.view.accessibilityIdentifier = "view_map"
        self.retryButton.accessibilityIdentifier = "btn_retry_error"
        self.tapOnInfolbl.accessibilityIdentifier = "lbl_taponinfo"
        
    }
    
    private func setupAccessibility(){
        self.shareBtn.accessibilityTraits = .button
        self.shareBtn.accessibilityLabel = LocalizationKeys.SCEventDetailVC.AccessibilityBtnShareContent.localized()
        self.shareBtn.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        eventTitleLabel.accessibilityTraits = .header
    }
    
    private func adaptFontSizes() {
        self.photoCreditLabel.adaptFontSize()
        self.categoryLabel.adaptFontSize()
        self.eventTitleLabel.adaptFontSize()
        self.singleDateTopLbl.adaptFontSize()
        self.singleDateBottomLbl.adaptFontSize()
        self.firstDateTopLbl.adaptFontSize()
        self.firstDateMiddleLbl.adaptFontSize()
        self.firstDateBottomLbl.adaptFontSize()
        self.secondDateMiddleLbl.adaptFontSize()
        self.secondDateBottomLbl.adaptFontSize()
        self.startTimeDescLbl.adaptFontSize()
        self.startTimeLbl.adaptFontSize()
        self.endTimeDescLbl.adaptFontSize()
        self.endTimeLbl.adaptFontSize()
        self.addToCslLbl.adaptFontSize()
        self.descMoreLinkLbl.adaptFontSize()
        self.descPdfTitle.adaptFontSize()
        self.descPdfLinkLbl.adaptFontSize()
        self.tapOnInfolbl.adaptFontSize()
    }
    
    private func setupDateBox(startDate: Date, endDate: Date){
        let sameDay = isSameDayFromDate(startDate: startDate, endDate: endDate)
        
        self.firstDateTopLbl.isHidden = sameDay
        self.firstDateMiddleLbl.isHidden = sameDay
        self.firstDateBottomLbl.isHidden = sameDay
        self.secondDateTopLbl.isHidden = sameDay
        self.secondDateMiddleLbl.isHidden = sameDay
        self.secondDateBottomLbl.isHidden = sameDay
        self.firstSecondSep.isHidden = sameDay
        
        self.singleDateTopLbl.isHidden = !sameDay
        self.singleDateBottomLbl.isHidden = !sameDay
        if sameDay {
            let calendarDate = Calendar.current.dateComponents([.day], from: startDate)
            self.singleDateBottomLbl.text = String(calendarDate.day!)
            var dayNameMonthText = getDayName(_for: startDate)
            dayNameMonthText.append(", ")
            dayNameMonthText.append(getMonthName(_for: startDate))
            self.singleDateTopLbl.text = dayNameMonthText
        } else {
            let startCalendarDate = Calendar.current.dateComponents([.day], from: startDate)
            let endCalendarDate = Calendar.current.dateComponents([.day], from: endDate)
            self.firstDateMiddleLbl.text = String(startCalendarDate.day!)
            self.secondDateMiddleLbl.text = String(endCalendarDate.day!)
            self.firstDateTopLbl.text = getDayName(_for: startDate)
            self.secondDateTopLbl.text = getDayName(_for: endDate)
            self.firstDateBottomLbl.text = getMonthName(_for: startDate)
            self.secondDateBottomLbl.text = getMonthName(_for: endDate)
        }
    }
    
    private func setupTimeBox(startDate: Date, endDate: Date, hasEndTime: Bool, hasStartTime: Bool){
        self.startTimeDescLbl.text = LocalizationKeys.SCEventDetailVC.e005StartTimeLabel.localized()
        if !hasStartTime {
            self.startTimeLbl.text = "--:--"
        } else {
            self.startTimeLbl.text = getTime(_for: startDate)
        }
        if !hasEndTime {
            self.endTimeLbl.text = "--:--"
        } else {
            self.endTimeLbl.text = getTime(_for: endDate)
        }
        self.endTimeDescLbl.text = LocalizationKeys.SCEventDetailVC.e005EndTimeLabel.localized()
    }
    
    func prepareMoreInfoWebview(contentURL : URL){
        let request = URLRequest(url: contentURL)
        self.webview = WKWebView()
        self.webview!.load(request)
        self.view.addSubview(webview!)
        self.webview!.isHidden = true
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        self.presenter.closeButtonWasPressed()
    }
    
    
    @IBAction func shareBtnWasPressed(_ sender: Any) {
        self.presenter.shareButtonWasPressed()
    }
    
    @objc func handleFavoriteViewTapped(_ sender: Any) {
        //TODO: Add "EventEngagement" event for favorite
        presenter.trackAdjustEvent(EventEngagementOption.favorite.rawValue)
        
        self.presenter.favoriteButtonWasTapped()
    }
    
    @objc func handleImageViewTapped(_ sender: Any) {
        self.presenter.imageViewWasTapped()
    }
    
    @objc func moreLinkWasPressed() {
        //TODO: Add "EventEngagement" event for moreInformation
        presenter.trackAdjustEvent(EventEngagementOption.moreInformation.rawValue)
        
        self.presenter.moreLinkButtonWasPressed()
    }
    
    @objc func addToCalendardWasPressed() {
        //TODO: Add "EventEngagement" event for addToCalendar
        presenter.trackAdjustEvent(EventEngagementOption.addToCalendar.rawValue)
        
        self.presenter.addToCalendardWasPressed()
    }
    
    @IBAction func retryBtnWasPressed(_ sender: Any) {
        self.retryButtonWasPressed()
    }
    
    func retryButtonWasPressed(){
        if SCUtilities.isInternetAvailable(){
            self.failedImageView.isHidden = false
            self.launchImage()
            
        }else{
            SCUtilities.topViewController().showUIAlert(with: LocalizationKeys.SCEventDetailVC.dialogRetryDescription.localized(), cancelTitle: LocalizationKeys.SCEventDetailVC.dialogButtonOk.localized(), retryTitle: LocalizationKeys.SCEventDetailVC.dialogRetryRetryButton.localized(), retryHandler: {self.retryButtonWasPressed()}, additionalButtonTitle: nil, additionButtonHandler: nil)
        }
    }
    
    private func configureUIForEvent(_ statusColor: UIColor, statusText: String) {
        eventStatusLabel.isHidden = false
        eventTitleSeperatorHeightConstraint.constant = 41.0
        eventStatusLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        eventStatusLabel.backgroundColor = statusColor
        eventStatusLabel.textColor = .white
        eventStatusLabel.textAlignment = .center
        eventStatusLabel.text = statusText
    }
}

// MARK: - SCEventDetailViewController
extension SCEventDetailViewController: SCEventDetailDisplaying {
    
    func setEventMarkedAsFavorite(isFavorite: Bool) {
        if isFavorite {
            self.favoriteStarImageView.image = UIImage(named: "icon_favourite_active")?.maskWithColor(color: kColor_cityColor)
        } else {
            self.favoriteStarImageView.image = UIImage(named: "icon_favourite_available")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!)
        }
    }
    
    
    func setupUI(navTitle : String,
                 title: String,
                 description: String,
                 endDate: Date,
                 startDate: Date,
                 hasEndTime: Bool,
                 hasStartTime: Bool,
                 imageURL: SCImageURL?,
                 latitude: Double,
                 longitude: Double,
                 locationName: String,
                 locationAddress: String,
                 imageCredit : String,
                 category : String,
                 pdf : [String]?,
                 link : String,
                 isFavorite: Bool,
                 eventStatus: EventStatus) {
        
        self.navigationItem.title = title
        let backButton = UIBarButtonItem()
        backButton.title  = LocalizationKeys.Common.navigationBarBack.localized()
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        if latitude == 0.0 && longitude == 0.0 && locationAddress.isSpaceOrEmpty() {
            self.hideMapView()
        } else {
            self.mapViewController?.setupMap(latitude: latitude,
                                             longitude: longitude,
                                             locationName: locationName,
                                             locationAddress: locationAddress,
                                             markerTintColor: kColor_cityColor,
                                             mapInteractionEnabled: false,
                                             showDirectionsBtn: false)
            
            self.mapHeightConstraint.constant = (mapViewController?.locationLblHeight ?? 0) + 160
            self.tapOnInfolbl.isHidden = self.mapHeightConstraint.constant != 0 ? false : true
            self.tapOnInfolblHeightConstraint.constant = 0
            
        }
        
        self.errorLabel.adaptFontSize()
        self.errorLabel.text = LocalizationKeys.SCEventDetailVC.e005ImageLoadError.localized()
        self.retryButton.setTitle(" " + LocalizationKeys.SCEventDetailVC.e002PageLoadRetry.localized(), for: .normal)
        self.retryButton.setTitleColor(kColor_cityColor, for: .normal)
        self.retryButton.titleLabel?.adaptFontSize()
        self.retryButton.setImage(UIImage(named: "action_resend_email")?.maskWithColor(color: kColor_cityColor), for: .normal)
        
        self.imageURL = imageURL
        self.launchImage()
        
        self.photoCreditLabel.text = "  " + imageCredit
        self.photoCreditLabel.backgroundColor = imageCredit.isEmpty ? UIColor.clear : UIColor(patternImage: UIImage(named: "darken_btm_large")!)
        
        self.eventTitleLabel.text = title
        self.categoryLabel.text = category
        self.addToCslLbl.text = LocalizationKeys.SCEventDetailVC.e005AddToCalendar.localized()
        self.favoritesLbl.text = LocalizationKeys.SCEventDetailVC.e005Favourite.localized()
        self.dateBox.layer.cornerRadius = 4.0
        self.dateBox.backgroundColor = kColor_cityColor
        self.setupDateBox(startDate: startDate, endDate: endDate)
        self.setupTimeBox(startDate: startDate, endDate: endDate, hasEndTime: hasEndTime, hasStartTime: hasStartTime)
        
        self.descDetailWebView.isHidden = !description.isEmpty ? false : true
        self.descDetail = description
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.loadWebView(with: description)
        })
        self.descShowMoreDetailBottomConstraint.constant = !self.descDetailWebView.isHidden ? self.descShowMoreDetailBottomConstraint.constant : 0
        
        self.descMoreSeperator.isHidden = !self.descDetailWebView.isHidden ? false : true
        self.descMoreLinkLbl.isHidden = !link.isEmpty ? false : true
        
        self.descMoreLinkLbl.text = LocalizationKeys.SCEventDetailVC.e005DescriptionReadMoreInformation.localized()
        self.descMoreLinkLbl.sizeToFit()
        self.descMoreLinkLbl.isUserInteractionEnabled = true
        let moreLinkTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.moreLinkWasPressed))
        self.descMoreLinkLbl.addGestureRecognizer(moreLinkTapGesture)
        self.descMoreLinkLbl.textColor = kColor_cityColor
        
        let addToCalendarTapImgGesture = UITapGestureRecognizer(target: self, action: #selector(self.addToCalendardWasPressed))
        let addToCalendarTapLblGesture = UITapGestureRecognizer(target: self, action: #selector(self.addToCalendardWasPressed))
        self.addToCslImageView.addGestureRecognizer(addToCalendarTapImgGesture)
        self.addToCslLbl.addGestureRecognizer(addToCalendarTapLblGesture)
        
        self.addToCslImageView.image = UIImage(named: "icon_add_to_calendar")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!)
        
        if link.count > 0 {
            if let url = URL(string: link){
                self.prepareMoreInfoWebview(contentURL: url)
                self.moreInfoURL = url
            }
        }
        
        if pdf?.count == 0 {
            let heightConstraint = NSLayoutConstraint(item:  self.pdfCardView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([heightConstraint])
        } else {
            self.descPdfTitle.text = LocalizationKeys.SCEventDetailVC.e005PdfLabel.localized()
            self.descPdfLinkLbl.text = pdf![0]
            self.descPdfLinkLbl.textColor = kColor_cityColor
        }
        
        switch eventStatus {
            
        case .cancelled :
            configureUIForEvent(.appointmentRejected, statusText: LocalizationKeys.SCEventDetailVC.e007EventCancelledDesc.localized())
            
        case .postponed :
            configureUIForEvent(.postponeEventStatus, statusText: LocalizationKeys.SCEventsOverviewTVC.e007EventsNewDateDesc.localized())
            
        case .soldout :
            configureUIForEvent(.appointmentRejected, statusText: LocalizationKeys.SCEventsOverviewTVC.e007EventsSoldOutDesc.localized())
            
        default :
            eventStatusLabel.isHidden = true
            eventTitleSeperatorHeightConstraint.constant = 10.0
        }
        
        self.tapOnInfolbl.text = LocalizationKeys.SCEventDetailVC.e006EventTapOnMapHint.localized()
    }
    
    private func loadWebView(with content: String?) {
        guard let content = content else { return }
        let fontSize = SCUtilities.fontSize(for: UIApplication.shared.preferredContentSizeCategory)
        let fontSetting = "<span style=\"font-family:-apple-system; font-size: \(fontSize); color: \(UIColor(named: "CLR_ICON_TINT_BLACK")!.hexString)\"</span>"
        descDetailWebView.webView.loadHTMLString(fontSetting + content, baseURL: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        descDetailWebView.webView.scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func hideMapView() {
        self.mapHeightConstraint.constant = 0.0
        // For hiding bottom seperator while map is not shown
        self.mapViewBottomSeperator.isHidden = true
        self.tapOnInfolbl.isHidden = true
        self.tapOnInfolblHeightConstraint.constant = 0
    }
    
    func showMoreInfoOverlay(_ show : Bool){
        if show {
            if self.webview != nil {
                if let url = moreInfoURL, UIApplication.shared.canOpenURL(url) {
                    SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
                }
            }
        } else {
            self.webview?.isHidden = true
        }
    }
    
    func noImageToShow(){
        self.imageView.isHidden = true
        self.imageViewHeightConstraint.constant = 0
        self.imageViewHeightConstraint1.constant = 0
        self.failedImageView.isHidden = true
        self.failedImageViewHeightConstraint.constant = 0
    }
    
    func loadImage(){
        if imageURL == nil || imageURL?.absoluteUrlString() == "" {
            self.noImageToShow()
            
        } else {
            self.imageView.isUserInteractionEnabled = false
            self.imageView.isHidden = false
            self.failedImageView.isHidden = true
            self.imageViewHeightConstraint.constant = 250
            
            self.imageView.load(from: imageURL, maxWidth:self.imageView.bounds.size.width) { isImageLoaded in
                if !isImageLoaded{
                    self.imageView.isHidden = true
                    self.failedImageView.isHidden = false
                    self.failedImageViewHeightConstraint.constant = 250
                    self.imageView.isUserInteractionEnabled = false
                }else{
                    self.imageView.isHidden = false
                    self.imageView.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    func launchImage(){
        self.failedImageView.isHidden = SCUtilities.isInternetAvailable()
        self.loadImage()
    }
    
    func isShowMoreInfoOverlayVisible() -> Bool{
        guard let hidden = self.webview?.isHidden else {
            return false
        }
        return !hidden
    }
    
    func showNeedsToLogin(with text : String, cancelCompletion: (() -> Void)?, loginCompletion: @escaping (() -> Void)) {
        self.showNeedsToLoginAlert(with: text, cancelCompletion: cancelCompletion, loginCompletion: loginCompletion)
    }
    
    
    func dismiss(completion: (() -> Void)?) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func push(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(viewController: UIViewController) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        self.present(viewController, animated: true)
    }
    
    func presentSnackBar(snackBarViewController: UIViewController, completion: (() -> Void)? = nil) {
        SCUtilities.topViewController().present(snackBarViewController, animated: true, completion: completion)
    }
    
    func presentFullImage(viewController: UIViewController) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        //blurView.alpha = 0.85
        blurView.frame = self.view.frame
        self.view.addSubview(blurView)
        viewController.modalPresentationStyle = .overCurrentContext
        self.present(viewController: viewController)
    }
    
    func removeBlurView() {
        for view in self.view.subviews {
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
    }
    
    func calculateDynamicHeight(_ view: UIView, maxHeight: CGFloat) -> CGFloat{
        let fixedWidth = view.frame.size.width
        let newSize = view.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let descDetailMaxHeight = newSize.height > maxHeight ? maxHeight : newSize.height
        return descDetailMaxHeight
    }
}

extension SCEventDetailViewController : SCMapViewDelegate {
    func mapWasTapped(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        self.presenter.mapViewWasPressed(latitude: latitude, longitude: longitude, zoomFactor: zoomFactor, address: address)
    }
    
    func directionsBtnWasPressed(latitude : Double, longitude : Double, address: String){
        //TODO: Add "EventEngagement" event for directions
        presenter.trackAdjustEvent(EventEngagementOption.directions.rawValue)
        
        self.presenter.directionsButtonWasPressed(latitude: latitude, longitude: longitude, address: address)
    }
    
}

extension SCEventDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!){
        
        let appearanceScript = """
                   var style = document.createElement('style');
                   style.textContent = '* { background-color: \(UIColor(named: "CLR_BCKGRND")!.hexDecimalString) !important; color: \(UIColor(named: "CLR_LABEL_TEXT_BLACK")!.hexDecimalString) !important; } a { color: \(kColor_cityColor.hexDecimalString) !important; }';
                   document.head.appendChild(style);
           """
        let customCss = """
        var style = document.createElement('style');
        style.textContent = '* { width: 99%; overflow-x: hidden; -webkit-hyphens: auto; hyphens: auto; }';
        document.head.appendChild(style);
        """
        webView.evaluateJavaScript(customCss, completionHandler: nil)
        webView.evaluateJavaScript(appearanceScript, completionHandler: nil)
        highlightURLs(webView)
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, _) in
            DispatchQueue.main.async { [weak self] in
                self?.descWebViewHeightConstaint?.constant = height as! CGFloat
            }
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
           let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            if url.scheme == "mailto" {
                //TODO: Add "EventEngagement" event for email
                presenter.trackAdjustEvent(EventEngagementOption.email.rawValue)
                
            } else if url.scheme == "tel" {
                //TODO: Add "EventEngagement" event for call
                presenter.trackAdjustEvent(EventEngagementOption.call.rawValue)
                
            } else {
                //TODO: Add "EventEngagement" event for website
                presenter.trackAdjustEvent(EventEngagementOption.website.rawValue)
            }
            
            SCInternalBrowser.showURL(url, withBrowserType: .safari, title: title)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    fileprivate func highlightURLs(_ webView: WKWebView) {
        let javascript = """
        function replaceURLs(regex, replacement) {
            function processNode(node) {
                if (node.nodeType === Node.TEXT_NODE) {
                    if (node.textContent.trim() !== '') {
                        var fragment = document.createDocumentFragment();
                        var remainingText = node.textContent;
                        var matches;
                        while ((matches = regex.exec(remainingText)) !== null) {
                            var match = matches[0];
                            var index = matches.index;
                            if (index > 0) {
                                fragment.appendChild(document.createTextNode(remainingText.substring(0, index)));
                            }
                            fragment.appendChild(replacement(match));
                            remainingText = remainingText.substring(index + match.length);
                        }
                        if (remainingText) {
                            fragment.appendChild(document.createTextNode(remainingText));
                        }
                        node.parentNode.replaceChild(fragment, node);
                    }
                } else if (node.nodeType === Node.ELEMENT_NODE && node.nodeName !== 'A' && node.nodeName !== 'SCRIPT' && node.nodeName !== 'STYLE') {
                    Array.from(node.childNodes).forEach(processNode);
                }
            }

            processNode(document.body);
        }

        var urlRegex = /(https?:\\/\\/[^\\s]+)/g;
        var emailRegex = /\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b/g;
        var phoneRegex = /(?:\\d{5}\\s\\d{6}|0?\\d{4,5}[\\/\\s]?\\d{6,7}|\\d{4,}\\s?\\/?\\s?\\d{3}\\s?\\d{3}|[1-9]\\d{8,})/g;

        replaceURLs(urlRegex, function(url) {
            var a = document.createElement('a');
            a.href = url;
            a.textContent = url;
            a.style.color = '\(kColor_cityColor.hexDecimalString)';
            return a;
        });

        replaceURLs(emailRegex, function(email) {
            var a = document.createElement('a');
            a.href = 'mailto:' + email;
            a.textContent = email;
            a.style.color = '\(kColor_cityColor.hexDecimalString)';
            return a;
        });

        replaceURLs(phoneRegex, function(phone) {
            var a = document.createElement('a');
            a.href = 'tel:' + phone;
            a.textContent = phone;
            a.style.color = '\(kColor_cityColor.hexDecimalString)';
            return a;
        });
        """
        webView.evaluateJavaScript(javascript, completionHandler: nil)
    }
}

