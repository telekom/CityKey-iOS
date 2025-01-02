//
//  SCLocationSubTableVC.swift
//  SmartCity
//
//  Created by Michael on 08.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit
import MessageUI

/**
 *
 * Delegate protocol for the cities tableview controller.
 *
 */
protocol SCLocationSubTableVCDelegate : NSObjectProtocol
{
    func determineLocationBtnWasPressed()
    func locationWasSelected(cityName: String, cityID : Int)
    func favDidChange(cityName : String, isFavorite: Bool)
    func isStoredLocationSuggestionAvailable() -> Bool
    func storedCityLocation() -> Int?
    func storedDistanceToNearestLocation() -> Double?
}

/*
 /**
  *
  * Data Source protocol for the cities tableview controller.
  *
  */
 protocol SCLocationSubTableVCDataSource : NSObjectProtocol
 {
 // list of all available cities
 func allCityItems() -> [CityLocationInfo]
 // list of current favorite  cities
 func favoriteCityItems() -> [CityLocationInfo]
 
 }
 */

class SCLocationSubTableVC: UITableViewController, MFMailComposeViewControllerDelegate {
    
    public var allCityItems: [CityLocationInfo]? {
        didSet {
            cityItemDictionary = [String: [CityLocationInfo]]()
            cityItemSectionTitles = [String]()
            
            if let items = allCityItems{
                for cityItem in items {
                    let cityItemKey = String(cityItem.cityName.prefix(1))
                    if var cityItemValues = cityItemDictionary[cityItemKey] {
                        cityItemValues.append(cityItem)
                        cityItemDictionary[cityItemKey] = cityItemValues
                    } else {
                        cityItemDictionary[cityItemKey] = [cityItem]
                    }
                }
                
                cityItemSectionTitles = [String](cityItemDictionary.keys)
                cityItemSectionTitles = cityItemSectionTitles.sorted(by: { $0 < $1 })
                
            }
        }
    }
    
    
    private var cityItemDictionary = [String: [CityLocationInfo]]()
    private var cityItemSectionTitles = [String]()
    private var locationService : SCGeoLocation?
    
    public var favoriteCityItems: [CityLocationInfo]?
    
    @IBOutlet weak var headerViewFederalLabel: UILabel!
    @IBOutlet weak var headerViewCityLabel: UILabel!
    @IBOutlet weak var roundBackView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var geoLocationView: UIView!
    @IBOutlet weak var locationHeaderLabel: UILabel!
    @IBOutlet weak var cityHeaderLabel: UILabel!
    @IBOutlet weak var refreshLocationLabel: UILabel!
    @IBOutlet weak var refreshSymbolView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
        
    @IBOutlet weak var contactLinkView: UIView!
    @IBOutlet weak var contactLinkTitleLabel: UILabel!
    @IBOutlet weak var contactLinkSubTitleLabel: UILabel!
    @IBOutlet weak var contactLinkImage: UIImageView!
    @IBOutlet var trailingSpaceFromRefreshViewConstraint: NSLayoutConstraint!
    @IBOutlet var trailingSpaceFromSuperViewConstraint: NSLayoutConstraint!

    
    weak var delegate : SCLocationSubTableVCDelegate?
    
    private var markForCityName : String?
    private var markColor : UIColor = UIColor(named: "CLR_LABEL_TEXT_BLACK")!
    private var activityCityName : String?
    
    private var onlyFavoritesVisible : Bool = false
    private var favoriteSelectionMode : Bool = false
    
    var tapGestureHeader : UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationService = SCGeoLocation()
        self.setupAccessibilityIDs()
        self.setupAccessibility()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        //adaptive Font Size
        setupContactLinkViewTapGesture()
        self.setupUI()
        handleDynamicTypeChange()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDynamicTypeChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }
    
    @objc private func handleDynamicTypeChange() {
        // Dynamic font
        tableView.estimatedRowHeight = 65.0
        tableView.rowHeight = UITableView.automaticDimension
        cityHeaderLabel.adjustsFontForContentSizeCategory = true
        cityHeaderLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 12.0, maxSize: 18.0)
        locationHeaderLabel.adjustsFontForContentSizeCategory = true
        locationHeaderLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 12.0, maxSize: 24.0)
        headerViewCityLabel.adjustsFontForContentSizeCategory = true
        headerViewCityLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18.0, maxSize: 28.0)
        headerViewFederalLabel.adjustsFontForContentSizeCategory = true
        headerViewFederalLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 11.0, maxSize: 18.0)
        refreshLocationLabel.adjustsFontForContentSizeCategory = true
        refreshLocationLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 13.0, maxSize: 20.0)
        contactLinkTitleLabel.adjustsFontForContentSizeCategory = true
        contactLinkTitleLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 17.0, maxSize: 26.0)
        contactLinkSubTitleLabel.adjustsFontForContentSizeCategory = true
        contactLinkSubTitleLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 22.0)
        
    }
    
    private func setupContactLinkViewTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTappable))
        contactLinkView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupUI() {
        self.refreshLocationLabel.adaptFontSize()
        self.cityHeaderLabel.text = "c_002_city_selection_list_header".localized()
        self.locationHeaderLabel.text = "c_002_cities_location_header".localized()
        self.refreshLocationLabel.text = "c_002_cities_turn_on_location".localized()
        self.geoLocationView.accessibilityLabel = "c_002_cities_turn_on_location".localized()
        self.contactLinkTitleLabel.text = LocalizationKeys.SCLocationSubTableVC.c003ContactLinkTitleText.localized()
        self.contactLinkSubTitleLabel.text = LocalizationKeys.SCLocationSubTableVC.c003ContactLinkSubTitleText.localized()
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
        self.refreshSymbolView.isHidden = true
        self.headerViewCityLabel.lineBreakMode = .byTruncatingTail
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // It will update location if location access is already given before.
        if (self.delegate?.isStoredLocationSuggestionAvailable() ?? false) ||  (locationService?.searchLocation() ?? false) {
            //update location
            self.updateLocation()
            if let storedLocationSuggestion: Int = self.delegate?.storedCityLocation(), let storedDistance: Double = self.delegate?.storedDistanceToNearestLocation() {
                self.showGeoLocatedCity(for: storedLocationSuggestion, distance: storedDistance)
            }
        }
        if (tapGestureHeader == nil) {
            tapGestureHeader = UITapGestureRecognizer(target: self, action: #selector(self.headerWasPressed))
            self.geoLocationView.addGestureRecognizer(tapGestureHeader!)
        }
    }
    
    @objc func willEnterForeground() {
        updateServiceNotAvailableConstraint()
    }
    
    @objc func viewTappable(){
        let alert = UIAlertController(title: nil, message: LocalizationKeys.SCLocationSubTableVC.c003ContactLinkMessageText.localized(), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: LocalizationKeys.SCLocationSubTableVC.c003AleartGetInContactButton.localized(), style: UIAlertAction.Style.default, handler: { action in
            self.sendMail()
        }))
        alert.addAction(UIAlertAction(title: LocalizationKeys.SCLocationSubTableVC.c003AleartCancelButton.localized(), style: UIAlertAction.Style.default, handler: { action in
            alert.dismiss(animated: true)
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    private func sendMail(){
        if MFMailComposeViewController.canSendMail(){
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setToRecipients(["citykey-support@telekom.de"])
            mailComposeViewController.setSubject(LocalizationKeys.SCLocationSubTableVC.c003MailSubjectText.localized())
            mailComposeViewController.setMessageBody("""
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyNameText.localized())
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyCityText.localized())
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyPermissionOne.localized())
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyPermissionTwo.localized())
                                                 """, isHTML: false)
            self.present(mailComposeViewController, animated: true, completion: nil)
        }
        else{
            let to = "citykey-support@telekom.de"
            let subject = LocalizationKeys.SCLocationSubTableVC.c003MailSubjectText.localized()
            let body = """
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyNameText.localized())
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyCityText.localized())
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyPermissionOne.localized())
                                                 \(LocalizationKeys.SCLocationSubTableVC.c003MailBodyPermissionTwo.localized())
                                                 """
            let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            
            let gmailUrl = (URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)"), "Gmail")
            let outlookUrl = (URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)"), "Outlook")
            let sparkUrl = (URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)"), "Spark")
            let yahooMail = (URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)"), "YahooMail")
            let availableUrls = [gmailUrl, outlookUrl, sparkUrl, yahooMail].filter { (item) -> Bool in
                return item.0 != nil && UIApplication.shared.canOpenURL(item.0!)
            }
            if availableUrls.isEmpty{
                let alert = UIAlertController(title: nil, message: LocalizationKeys.SCVersionInformationViewController.wn005MailAleartText.localized(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: LocalizationKeys.SCCitizenSurveyPageViewPresenter.p001ProfileConfirmEmailChangeBtn.localized(), style: UIAlertAction.Style.default, handler: { action in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            }else{
                self.showEmailOptions(for: availableUrls as! [(url: URL, friendlyName: String)])
            }
            
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func showEmailOptions(for items: [(url: URL, friendlyName: String)]) {
        let ac = UIAlertController(title: LocalizationKeys.SCLocationSubTableVC.c003EmailOptionAleartText.localized(), message: nil, preferredStyle: .actionSheet)
            for item in items {
                ac.addAction(UIAlertAction(title: item.friendlyName, style: .default, handler: { (_) in
                    UIApplication.shared.open(item.url, options: [:], completionHandler: nil)
                }))
            }
        ac.addAction(UIAlertAction(title: LocalizationKeys.SCDefectReporterLocationViewController.c001CitiesDialogGpsBtnCancel.localized(), style: .cancel, handler: nil))
            present(ac, animated: true)
    }
    // setup accessibility ids for automated testing
    private func setupAccessibilityIDs(){
        self.refreshLocationLabel.accessibilityIdentifier = "lbl_refresh"
        self.navigationController?.navigationBar.accessibilityIdentifier = "nvbr"
        self.navigationItem.titleView?.accessibilityIdentifier = "nvitem_title"
    }

    private func setupAccessibility(){
        self.view.accessibilityViewIsModal = true
        self.cityHeaderLabel.accessibilityTraits = .header
        self.cityHeaderLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.locationHeaderLabel.accessibilityTraits = .header
        self.locationHeaderLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.refreshLocationLabel.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.refreshLocationLabel.accessibilityTraits = .button
        self.geoLocationView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
        self.geoLocationView.isAccessibilityElement = true
        self.headerViewCityLabel.accessibilityElementsHidden = true
        self.headerViewFederalLabel.accessibilityElementsHidden = true
        self.headerViewCityLabel.accessibilityElementsHidden = true
        self.refreshSymbolView.accessibilityElementsHidden = true
        self.refreshLocationLabel.accessibilityElementsHidden = true
        self.roundBackView.accessibilityElementsHidden = true
        self.contactLinkTitleLabel.accessibilityElementsHidden = true
        self.contactLinkSubTitleLabel.accessibilityElementsHidden = true
        self.contactLinkView.isAccessibilityElement = true
        self.contactLinkView.accessibilityTraits = .button
        self.contactLinkView.accessibilityLabel = LocalizationKeys.SCLocationSubTableVC.c003ContactLinkTitleText.localized() + LocalizationKeys.SCLocationSubTableVC.c003ContactLinkSubTitleText.localized()
        self.contactLinkView.accessibilityLanguage = SCUtilities.preferredContentLanguage()
    }

    public func reloadData() {
        self.tableView.reloadSectionIndexTitles()
        self.tableView.reloadData()
    }
        
    func showLocationMarker(for cityName : String, color: UIColor?) {
        if let markColor = color {
            self.markColor = markColor
        }
        
        self.markForCityName = cityName
        
        self.reloadData()
    }
    
    func showGeoLocatedCity(for cityId: Int, distance: Double) {
        self.configureNearestLocation(cityId: cityId, distance: distance)
    }
    
    func showLocationMarkerForLastSelected() {
        self.showLocationMarker(for: self.activityCityName ?? "", color: nil)
        self.activityCityName = nil
        self.reloadData()
    }
    
    func showLocationActivityIndicator(for cityName : String) {
        self.activityCityName = cityName
        self.markForCityName = nil
        self.reloadData()
    }

    func hideLocationActivityIndicator() {
        self.activityCityName = nil
        self.markForCityName = nil
        self.reloadData()
    }

    func searchLocActivityIndicator(show : Bool) {
        if show {
            self.refreshSymbolView.isHidden = true
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func configureNearestLocation(cityId: Int, distance: Double) {
        let distanceString = self.prepareDistanceString(distance: distance)
        if let locationInfo = self.locationInfoForCityId(cityId: cityId) {
            SCImageLoader.sharedInstance.getImage(with: locationInfo.cityImageUrl, completion: { (image, loadingError) in
                if loadingError == nil {
                    self.roundBackView.image = image
                    self.roundBackView.clipsToBounds = true
                    self.roundBackView.layer.cornerRadius = self.roundBackView.frame.size.width/2
                    self.refreshLocationLabel.isHidden = true
                    self.headerViewCityLabel.text = locationInfo.cityName + distanceString
                    self.headerViewFederalLabel.text = locationInfo.cityState
                    self.headerViewCityLabel.isHidden = false
                    self.headerViewFederalLabel.isHidden = false
                    self.geoLocationView.accessibilityLabel = locationInfo.cityName + distanceString + ", " + locationInfo.cityState
                    self.geoLocationView.accessibilityHint = "accessibility_cell_dbl_click_hint".localized()
                    self.refreshSymbolView.isHidden = true
                    UIAccessibility.post(notification: .layoutChanged, argument: self.geoLocationView)
                }
            })
        }
    }
    
    func configureLocationServiceNotAvailable() {
        self.roundBackView.image = UIImage(named: "icon_compass_fail_dark")
        self.headerViewCityLabel.isHidden = true
        self.headerViewFederalLabel.isHidden = true
        self.refreshLocationLabel.isHidden = false
        self.refreshSymbolView.isHidden = false
        updateServiceNotAvailableConstraint()
        self.geoLocationView.accessibilityLabel = "c_002_cities_turn_on_location".localized()
        UIAccessibility.post(notification: .layoutChanged, argument: self.geoLocationView)

    }
    
    private func updateServiceNotAvailableConstraint() {
        self.trailingSpaceFromRefreshViewConstraint.isActive = self.refreshSymbolView.isHidden ? false : true
        self.trailingSpaceFromSuperViewConstraint.isActive = !trailingSpaceFromRefreshViewConstraint.isActive
    }
    
    func prepareDistanceString(distance: Double) -> String {
        let distanceInteger = Int(distance)
        let distanceString = " (" + String(distanceInteger) + " km" + ")"
        return distanceString
    }

    func locationInfoForCityId(cityId: Int) -> CityLocationInfo? {
        if let cityItems = allCityItems {
            for location in cityItems {
                if location.cityID == cityId {
                    return location
                }
            }
        }
        return nil
    }
    
    private func isCityMarked(cityName: String) -> Bool {
        return self.markForCityName?.lowercased() == cityName.lowercased()  && !self.favoriteSelectionMode
    }
    
    
    // MARK: - Table view data source

    func indexPathHasValidCount(_ indexPath: IndexPath) -> Bool {
            return indexPath.count == 2
        }
        
    func indexPathIsInBounds(_ indexPath: IndexPath) -> Bool {
        return indexPath.section >= 0 && indexPath.row >= 0 && indexPath.section < self.tableView.numberOfSections && indexPath.row < self.tableView.numberOfRows(inSection: indexPath.section)
    }
    
    func absoluteIndex(with indexPath: IndexPath) -> Int? {
        guard indexPathHasValidCount(indexPath), indexPathIsInBounds(indexPath) else { return nil }
        var index = 0
        if indexPath.section > 0 {
            for i in 0..<indexPath.section {
                index += self.tableView.numberOfRows(inSection: i)
            }
        }
        index += (indexPath.row)
        return index
    }
    
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]?{
//        if self.onlyFavoritesVisible {
//            return [String]()
//        }
//
//        return self.cityItemSectionTitles as [String]
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 
        let cityItemKey = cityItemSectionTitles[section]
        if let cityItemValues = cityItemDictionary[cityItemKey] {
            return cityItemValues.count
        }
            
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cityItemSectionTitles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"LocationCellRegular", for: indexPath) as! SCLocationCell
        
        let cityItemKey = cityItemSectionTitles[indexPath.section]
        
        if let cityItemValues = cityItemDictionary[cityItemKey] {
            
            let city = cityItemValues[indexPath.row]
            
            cell.imageCityView.load(from: city.cityImageUrl)
            // Make image circular
            cell.imageCityView.layer.cornerRadius = cell.imageCityView.frame.size.width / 2
            cell.imageCityView.clipsToBounds = true
            cell.imageCityView.layer.borderWidth = 1
            cell.imageCityView.layer.borderColor = UIColor(named: "CLR_BORDER_SILVERGRAY")!.cgColor
            cell.imageBackgroundView.layer.cornerRadius = cell.imageBackgroundView.frame.size.width/2
            cell.imageBackgroundView.isHidden = !isCityMarked(cityName: city.cityName)
            cell.imageBackgroundBlackView.layer.cornerRadius = cell.imageBackgroundBlackView.frame.size.width/2
            cell.imageBackgroundBlackView.isHidden = !isCityMarked(cityName: city.cityName)
            cell.cityLabel.adjustsFontForContentSizeCategory = true
            cell.stateLabel.adjustsFontForContentSizeCategory = true
            cell.stateLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 14, maxSize: 20)
            cell.cityLabel.text = city.cityName
            cell.cityLabel.font = isCityMarked(cityName: city.cityName) ? UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: 28) : UIFont.SystemFont.regular.forTextStyle(style: .body, size: 18, maxSize: 28)
            cell.cityLabel.accessibilityIdentifier = city.cityName
            cell.stateLabel.text = city.cityState
            if isCityMarked(cityName: city.cityName) {
                cell.backgroundColor = UIColor(named: "CLR_LISTITEM_ACTIVE")
                cell.backView.backgroundColor = UIColor(named: "CLR_LISTITEM_ACTIVE")
            }else{
                cell.backgroundColor = UIColor(named: "CLR_CELL_BACKGRND")
                cell.backView.backgroundColor = UIColor(named: "CLR_CELL_BACKGRND")
            }
            cell.selectionModeStyle(self.favoriteSelectionMode)
            
            // set accessibilty information
            cell.cityLabel.accessibilityElementsHidden = true
            cell.stateLabel.accessibilityElementsHidden = true
            cell.imageCityView.accessibilityElementsHidden = true
            cell.imageBackgroundView.accessibilityElementsHidden = true
            cell.imageBackgroundBlackView.accessibilityElementsHidden = true

            let accItemString = String(format:"accessibility_table_selected_cell".localized().replaceStringFormatter(), String(( absoluteIndex(with: indexPath) ?? 0) + 1), String(allCityItems?.count ?? 1))
            cell.accessibilityTraits = .button
            cell.accessibilityHint = isCityMarked(cityName: city.cityName) ? "active_city_voice_over_text".localized() : "accessibility_location_cell_dbl_click_hint".localized()
            cell.accessibilityLabel = accItemString + ", " + city.cityName + ", " + city.cityState
            cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            cell.isAccessibilityElement = true

            if (activityCityName?.lowercased() == city.cityName.lowercased()) {
                cell.activityIndicatorView.startAnimating()
            } else {
                cell.activityIndicatorView.stopAnimating()
            }

        }

        return cell
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func viewDidLayoutSubviews() {
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        SCUserDefaultsHelper.setCityStatus(status: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cityItemKey = cityItemSectionTitles[indexPath.section]

        if let cell = tableView.cellForRow(at: indexPath) as? SCLocationCell {
            cell.accessibilityLabel = "accessibility_loading_city".localized()
            cell.activityIndicatorView.startAnimating()
            UIAccessibility.post(notification: .layoutChanged, argument: cell)
        }
        
        if let cityItemValues = cityItemDictionary[cityItemKey] {
            let city = cityItemValues[indexPath.row]
            self.delegate?.locationWasSelected(cityName : city.cityName, cityID: city.cityID)
        }
    }

    // MARK: - Btn and Gesture Actions

    @objc func headerWasPressed() {
        if let delegate = self.delegate {
            if (!delegate.isStoredLocationSuggestionAvailable()){
                self.delegate?.determineLocationBtnWasPressed()
            } else {
                self.geoLocationView.accessibilityLabel = "accessibility_loading_city".localized()
                UIAccessibility.post(notification: .layoutChanged, argument: self.geoLocationView)
                self.delegate?.locationWasSelected(cityName: "", cityID: delegate.storedCityLocation()!)
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    func updateLocation() {
        self.delegate?.determineLocationBtnWasPressed()
    }
    
}
