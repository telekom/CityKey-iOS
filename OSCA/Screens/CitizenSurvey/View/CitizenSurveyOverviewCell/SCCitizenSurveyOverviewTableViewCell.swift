/*
Created by Rutvik Kanbargi on 09/12/20.
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
