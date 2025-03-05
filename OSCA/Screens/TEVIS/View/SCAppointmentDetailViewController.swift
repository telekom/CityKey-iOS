/*
Created by Rutvik Kanbargi on 24/07/20.
Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol SCAppointmentDetailDisplaying: AnyObject, SCDisplaying {
    func showCancelMeetingAlert(with cancelCompletion: (() -> Void)?, okCompletion: (() -> Void)?)
    func displayCancelMeetingBtn(_ enabled : Bool)
    func hideMap()
    func showMap(latitude: Double,
    longitude: Double,
    locationName: String,
    locationAddress: String,
    markerTintColor: UIColor,
    mapInteractionEnabled: Bool,
    showDirectionsBtn: Bool)
    func present(viewController: UIViewController)
    func popViewController()
    func stopLoadingIndicator()
    func showAlert(title:String,message:String, OkButton: String )
}

class SCAppointmentDetailViewController: UIViewController {

    @IBOutlet weak var appointmentSetDateLabel: UILabel!
    @IBOutlet weak var appointmentTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var appointmentDayLabel: UILabel!
    @IBOutlet weak var appointmentDateLabel: UILabel!
    @IBOutlet weak var appointmentDateContainerView: UIView!

    @IBOutlet weak var startTimePlaceholderLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimePlaceholderLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    @IBOutlet weak var addToCalendarLabel: UILabel!
    @IBOutlet weak var addToCalendarContainerView: UIControl!
    @IBOutlet weak var addToCalendarImage: UIImageView!
    @IBOutlet weak var qrCodeContainerView: UIControl!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!

    @IBOutlet weak var concernStackView: UIStackView!
    @IBOutlet weak var concernPlaceholderLabel: UILabel!
    @IBOutlet weak var concernLabel: UILabel!
    @IBOutlet weak var waitingNumberLabel: UILabel!

    @IBOutlet weak var participantStackView: UIStackView!
    @IBOutlet weak var participantPlaceholderLabel: UILabel!
    @IBOutlet weak var participantLabel: UILabel!

    @IBOutlet weak var bringWithStackView: UIStackView!
    @IBOutlet weak var bringWithPlaceholderLabel: UILabel!
    @IBOutlet weak var bringWithLabel: UILabel!

    @IBOutlet weak var responsibleStackView: UIStackView!
    @IBOutlet weak var responsiblePlaceholderLabel: UILabel!
    @IBOutlet weak var responsibleLabel: UILabel!

    @IBOutlet weak var additionalStackView: UIStackView!
    @IBOutlet weak var additionalPlaceholderLabel: UILabel!
    @IBOutlet weak var additionalLabel: UILabel!
    
    
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var bottomBtn: SCCustomButton!
    @IBOutlet weak var bottomBtnOuterView: UIView!
    
    @IBOutlet weak var tapOnInfolbl: UILabel!

    var presenter: SCAppointmentDetailPresenting?
    var mapViewController: SCMapViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter?.set(display: self)
        presenter?.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        self.appointmentSetDateLabel.adaptFontSize()
        self.appointmentTitleLabel.adaptFontSize()
        self.appointmentDayLabel.adaptFontSize()
        self.appointmentDateLabel.adaptFontSize()
        self.startTimePlaceholderLabel.adaptFontSize()
        self.startTimeLabel.adaptFontSize()
        self.endTimePlaceholderLabel.adaptFontSize()
        self.endTimeLabel.adaptFontSize()
        self.addToCalendarLabel.adaptFontSize()
        self.qrCodeLabel.adaptFontSize()
        self.concernPlaceholderLabel.adaptFontSize()
        self.concernLabel.adaptFontSize()
        self.waitingNumberLabel.adaptFontSize()
        self.participantPlaceholderLabel.adaptFontSize()
        self.participantLabel.adaptFontSize()
        self.bringWithPlaceholderLabel.adaptFontSize()
        self.bringWithLabel.adaptFontSize()
        self.responsiblePlaceholderLabel.adaptFontSize()
        self.responsibleLabel.adaptFontSize()
        self.addressLabel.adaptFontSize()
        self.tapOnInfolbl.adaptFontSize()
        
        self.title = LocalizationKeys.SCAppointmentDetailViewController.apnmt003PageTitle.localized()
        imageView.load(from: presenter?.getServiceImage(),
                       maxWidth: imageView.bounds.width)
        appointmentTitleLabel.text = presenter?.getAppointmentTitle()
        appointmentSetDateLabel.text = presenter?.getAppointmentSetDate()
        startTimePlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.e005StartTimeLabel.localized()
        startTimeLabel.text = presenter?.getAppointmentStartTime()
        endTimePlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.e005EndTimeLabel.localized()
        endTimeLabel.text = presenter?.getAppointmentEndTime()

        addToCalendarLabel.text = LocalizationKeys.SCAppointmentDetailViewController.e005AddToCalendar.localized()
        addToCalendarImage.image = UIImage(named: "icon_add_to_calendar")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!)
        let calendarViewConfig = presenter?.getAddToCalendarViewConfiguration()
        addToCalendarContainerView.isUserInteractionEnabled = calendarViewConfig?.isAvailable ?? false
        addToCalendarContainerView.alpha = calendarViewConfig?.alpha ?? 0.2

        qrCodeLabel.text = LocalizationKeys.SCAppointmentDetailViewController.apnmt002ShowQrCodeButton.localized()
        qrCodeImage.image = UIImage(named: "QR-Code Icon Black")?.maskWithColor(color: UIColor(named: "CLR_ICON_SCND_ACTION")!)
        let qrCodeViewConfig = presenter?.getQRCodeViewConfiguration()
        qrCodeContainerView.isUserInteractionEnabled = qrCodeViewConfig?.isAvailable ?? false
        qrCodeContainerView.alpha = qrCodeViewConfig?.alpha ?? 0.2

        appointmentDayLabel.text = presenter?.getAppointmentDayMonthPresentable()
        appointmentDateLabel.text = presenter?.getAppointmentDate()
        appointmentDateContainerView.addCornerRadius()

        concernPlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.apnmt003ConcernsLabel.localized()
        waitingNumberLabel.text = presenter?.getAppointmentWaitingNumber(waitingTitle: LocalizationKeys.SCAppointmentDetailViewController.apnmt003WaitingNoFormat.localized().replaceStringFormatter())
        let concernText = presenter?.getAppointmentReason()
        concernLabel.text = concernText
        concernStackView.isHidden = concernText == ""

        participantPlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.apnmt003ParticipantsLabel.localized()
        let participantText = presenter?.getAppointmentParticipant()
        participantLabel.text = participantText
        participantStackView.isHidden = participantText == ""

        // Currently this data is not avaiable in API
        bringWithPlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.apnmt003BringWithLabel.localized()
        let bringWithText = presenter?.getAppointmentBringWith()
        bringWithLabel.text = bringWithText
        bringWithStackView.isHidden = bringWithText == ""

        // Currently this data is not avaiable in API
        additionalPlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.apnmt003AdditionalLabel.localized()
        let additionalText = presenter?.getAppointmentAdditional()
        additionalLabel.text = additionalText
        additionalStackView.isHidden = additionalText == ""

        responsiblePlaceholderLabel.text = LocalizationKeys.SCAppointmentDetailViewController.apnmt003ResponsibleLabel.localized()
        let responsibleText = presenter?.getAppointmentContactDescription()
        responsibleLabel.text = responsibleText
        responsibleStackView.isHidden = responsibleText == ""

        addressLabel.attributedText = presenter?.getAppointmentAddressPresentable()
        addShareBarButton()
        
        bottomBtn.setTitle(LocalizationKeys.SCAppointmentDetailViewController.apnmt003CancelAppointmentBtn.localized(), for: .normal)
        bottomBtn.customizeBlueStyleLight()
        
        self.tapOnInfolbl.text = LocalizationKeys.SCAppointmentDetailViewController.e006EventTapOnMapHint.localized()

    }

    private func addShareBarButton() {
        navigationItem.rightBarButtonItem = presenter?.getRightBarButton()
    }

    @IBAction func didTapOnAddToCalendar(_ sender: UIControl) {
        presenter?.addAppointmentToCalendar()
    }

    @IBAction func didTapOnQRCode(_ sender: UIControl) {
        presenter?.displayQRCodeViewController()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let viewController as SCMapViewController:
            mapViewController = viewController
            mapViewController?.title = LocalizationKeys.SCAppointmentDetailViewController.apnmt003PageTitle.localized()
            mapViewController?.delegate = self

        default:
            break
        }
    }

    @objc private func didTapOnShare() {
        presenter?.share()
    }

    @IBAction func didTapOnBottomBtn(_ sender: Any) {
        bottomBtn.btnState = .progress
        self.presenter?.bottomBtnWasPressed()
    }
}

extension SCAppointmentDetailViewController: SCAppointmentDetailDisplaying {

    func displayCancelMeetingBtn(_ enabled : Bool){
        self.bottomBtnOuterView.isHidden = !enabled
    }
    
    func showCancelMeetingAlert(with cancelCompletion: (() -> Void)? = nil, okCompletion: (() -> Void)? = nil) {


        let alert = UIAlertController(title: LocalizationKeys.SCAppointmentDetailViewController.apnmt003CancelApnmtTitle.localized(),
                                      message: LocalizationKeys.SCAppointmentDetailViewController.apnmt003CancelApnmtInfo.localized(),
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: LocalizationKeys.SCAppointmentDetailViewController.apnmt003CancelApnmtCancel.localized(), style: .cancel, handler: { (action) -> Void in
            DispatchQueue.main.async {
                cancelCompletion?()
            }})
        let ok = UIAlertAction(title: LocalizationKeys.SCAppointmentDetailViewController.apnmt003CancelApnmtOk.localized(), style: .default, handler: { (action) -> Void in
            DispatchQueue.main.async {
                okCompletion?()
            }})
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        self.present(alert, animated: true, completion: nil)
    }

    func hideMap() {
        mapViewHeightConstraint.constant = 0
        self.tapOnInfolbl.isHidden = true
    }

    func showMap(latitude: Double = 0.0, longitude: Double = 0.0, locationName: String, locationAddress: String, markerTintColor: UIColor = kColor_cityColor, mapInteractionEnabled: Bool = true, showDirectionsBtn: Bool = false) {
        mapViewController?.setupMap(latitude: latitude,
                                    longitude: longitude,
                                    locationName: locationName,
                                    locationAddress: locationAddress,
                                    markerTintColor: markerTintColor,
                                    mapInteractionEnabled: mapInteractionEnabled,
                                    showDirectionsBtn: showDirectionsBtn)
    }

    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

    func stopLoadingIndicator() {
        bottomBtn.btnState = .normal
    }
    
    func showAlert(title:String,message:String, OkButton: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction( UIAlertAction(title: OkButton, style: .default, handler: nil ) )
        present(viewController: alertController)        
    }
}

extension SCAppointmentDetailViewController: SCMapViewDelegate {

    func mapWasTapped(latitude: Double, longitude: Double, zoomFactor: Float, address: String) {
        presenter?.mapViewWasPressed(latitude: latitude,
                                     longitude: longitude,
                                     zoomFactor: zoomFactor,
                                     address: address)
    }

    func directionsBtnWasPressed(latitude: Double, longitude: Double, address: String) {
    }
}
