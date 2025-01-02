//
//  SCCitizenSurveyOverviewTableViewCell.swift
//  OSCA
//
//  Created by Rutvik Kanbargi on 09/12/20.
//  Copyright © 2020 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

class SCCitizenSurveyOverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var surveyNameLabel: UILabel!
    @IBOutlet weak var surveyDescriptionLabel: UILabel!

    @IBOutlet weak var unreadSurveyIndicatorView: UIView!
    @IBOutlet weak var surveyProgressImageView: UIImageView!
    @IBOutlet weak var surveyDaysLeftView: SCSurveyDaysLeftView!
    @IBOutlet weak var surveyPopularView: SCFavouriteView!
    @IBOutlet weak var surveyStackView: UIStackView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var surveyNameLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var surveyDescLblHeightConstraint: NSLayoutConstraint!

    var isSurveyRead: Bool = false {
        didSet {
            unreadSurveyIndicatorView.isHidden = isSurveyRead
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func set(survey: SCModelCitizenSurveyOverview) {
        surveyDescriptionLabel.adjustsFontForContentSizeCategory = true
        surveyNameLabel.text = survey.name
        surveyDescriptionLabel.attributedText = formattedSurvey(description: survey.description)
        isSurveyRead = true

        let surveyStatusViewConfig = survey.status.getViewConfiguration()
        surveyPopularView.isHidden = !survey.isPopular
        surveyProgressImageView.image = surveyStatusViewConfig.progressImage
        surveyProgressImageView.isHidden = surveyStatusViewConfig.progressImage == nil

        if Date().difference(from: survey.startDate) > 0 {
            surveyDaysLeftView.setProgress(to: survey.getDaysLeftProgress(), daysLeft: 00)
        } else {
            surveyDaysLeftView.setProgress(to: survey.getDaysLeftProgress(), daysLeft: survey.daysLeft )
        }
        
        
        // SMARTC-20104 Client: Survey "title" text is trimmed and "description" text should be truncated to 3 lines on Surveys screen
        
        surveyStackView.isHidden = surveyPopularView.isHidden && surveyProgressImageView.isHidden

        let widthTitle = (surveyPopularView.isHidden ? surveyPopularView.frame.width : 0.0) + (surveyProgressImageView.isHidden ? surveyProgressImageView.frame.width : 0.0)
        let heightTitle = Double((surveyNameLabel?.frame.origin.y)! + (surveyNameLabel?.text?.estimatedHeight(withConstrainedWidth: self.surveyNameLabel.frame.width + widthTitle, font: (surveyNameLabel?.font)!))!)
        surveyNameLblHeightConstraint.constant = CGFloat(heightTitle)
    
    }

    private func formattedSurvey(description: String?) -> NSAttributedString {
        guard let attributedSurveyDescription = description?.htmlAttributedString else {
            return NSAttributedString(string: "")
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        let font = UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16.0, maxSize: 20.0)
        
        let surveyDescription = NSMutableAttributedString(attributedString: attributedSurveyDescription)
        surveyDescription.addAttributes([.font: font,
                                         .paragraphStyle: paragraphStyle,
                                         .foregroundColor: UIColor(named: "CLR_LABEL_TEXT_BLACK")!],
                                        range: NSRange(0..<attributedSurveyDescription.length))
        return surveyDescription
    }
}
