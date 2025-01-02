//
//  SCCitizenSurveyDetailViewController.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 08/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCCitizenSurveyDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var surveyPostedDateLabel: UILabel!
    @IBOutlet weak var surveyNameLabel: UILabel!

    @IBOutlet weak var surveyStatusPopularView: SCFavouriteView!
    @IBOutlet weak var surveyProgressImageView: UIImageView!

    @IBOutlet weak var surveyEndDatePlaceholderLabel: UILabel!
    @IBOutlet weak var surveyEndDateLabel: UILabel!

    @IBOutlet weak var surveyHeadingLabel: UILabel!
    @IBOutlet weak var surveyDescriptionLabel: UILabel!

    @IBOutlet weak var startSurveyButton: SCCustomButton!
    @IBOutlet weak var daysLeftView: SCSurveyDaysLeftView!
    @IBOutlet weak var surveyCompletionLabel: UILabel!

    var presenter: SCCitizenSurveyDetailPresenting?

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        self.presenter?.viewDidLoad()
        setupAccessibility()
        handleDynamicTypeChange()
        SCDataUIEvents.registerNotifications(for: self, on: UIContentSizeCategory.didChangeNotification, with: #selector(handleDynamicTypeChange))
    }

    private func setup() {
        title = LocalizationKeys.SCCitizenSurveyOverviewViewController.cs002PageTitle.localized()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: LocalizationKeys.Common.navigationBarBack.localized(),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)

        presenter?.set(display: self)
        imageView.load(from: presenter?.getSurveyImage())
        surveyPostedDateLabel.text = presenter?.getSurveyPresentableStartDate()
        surveyNameLabel.text = presenter?.getSurveyTitle()
        surveyEndDatePlaceholderLabel.text = presenter?.getSurveyEndDatePlaceholder()
        surveyEndDateLabel.text = presenter?.getSurveyPresentableEndDate()
        surveyHeadingLabel.text = presenter?.getSurveyHeading()
        surveyDescriptionLabel.attributedText = presenter?.getSurveyDescription()

        let surveyStatusViewConfig = (presenter?.getSurveyStatus() ?? .toBeStart).getViewConfiguration()
        surveyStatusPopularView.isHidden = !(presenter?.getSurveyIsPopular() ?? false)
        surveyProgressImageView.image = surveyStatusViewConfig.progressImage
        surveyProgressImageView.isHidden = (surveyStatusViewConfig.progressImage == nil)

        startSurveyButton.customizeCityColorStyle()
        startSurveyButton.setTitle(LocalizationKeys.SCCitizenSurveyDetailViewController.cs003ButtonText.localized(), for: .normal)
        startSurveyButton.btnState = (!surveyStatusViewConfig.isFinished) ? .normal : .disabled
        surveyCompletionLabel.text = LocalizationKeys.SCCitizenSurveyDetailViewController.cs002SurveyCompletedMessage.localized()
        startSurveyButton.isHidden = (!surveyStatusViewConfig.isFinished) ? false : true
        surveyCompletionLabel.isHidden = (!surveyStatusViewConfig.isFinished) ? true : false

        let daysLeftProgress = presenter?.getSurveyDaysLeftViewProgress() ?? (1.0, 0)
        daysLeftView.setProgress(to: daysLeftProgress.0, daysLeft: daysLeftProgress.1)

//        Temporary commented as share functionality is not implemented yet
//        addBarButtonItem()
    }

    @objc private func handleDynamicTypeChange() {
        surveyPostedDateLabel.adjustsFontForContentSizeCategory = true
        surveyPostedDateLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 12.0, maxSize: 20.0)
        surveyNameLabel.adjustsFontForContentSizeCategory = true
        surveyNameLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 24.0, maxSize: 40.0)
        surveyHeadingLabel.adjustsFontForContentSizeCategory = true
        surveyHeadingLabel.font = UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18.0, maxSize: 30.0)
        surveyDescriptionLabel.adjustsFontForContentSizeCategory = true
        surveyDescriptionLabel.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 28.0)
        startSurveyButton.titleLabel?.adjustsFontForContentSizeCategory = true
        startSurveyButton.titleLabel?.font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 15.0, maxSize: 28.0)
        let daysLeftProgress = presenter?.getSurveyDaysLeftViewProgress() ?? (1.0, 0)
        daysLeftView.setProgress(to: daysLeftProgress.0, daysLeft: daysLeftProgress.1)
    }
    
    private func setupAccessibility() {
        surveyNameLabel.accessibilityTraits = .header
        surveyNameLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 1)) \(presenter?.getSurveyTitle() ?? "")"
        surveyHeadingLabel.accessibilityTraits = .header
        surveyHeadingLabel.accessibilityLabel = "\(SCUtilities.getHeaderStringWith(level: 2)) \(presenter?.getSurveyHeading() ?? "")"
    }

    private func addBarButtonItem() {
        navigationItem.rightBarButtonItem = presenter?.getShareButton()
    }

    @IBAction func didTapOnStartSurvey(_ sender: UIButton) {
        presenter?.displayDataPrivacyViewController(delegate: self)
    }
}

extension SCCitizenSurveyDetailViewController: SCCitizenSurveyDetailDisplaying {
 
    func showBtnActivityIndicator(_ show : Bool) {
        self.startSurveyButton.btnState = show ? .progress : .normal
    }

    func push(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}

extension SCCitizenSurveyDetailViewController: SCCitizenSurveyDetailViewDelegate {

    func acceptedDataPrivacy() {
        presenter?.displaySurveyQuestionViewController()
    }
}
