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

fileprivate struct SCCitizenSurveyDataSoureModel {
    let surveyList: [SCModelCitizenSurveyOverview]
    let sectionTitle: String
}

class SCCitizenSurveyDataSource {

    fileprivate var surveyDataDict: [Int: SCCitizenSurveyDataSoureModel] = [:]

    init(surveyList: [SCModelCitizenSurveyOverview]) {
        var ongoingSurveyList: [SCModelCitizenSurveyOverview] = []
        var completedSurveyList: [SCModelCitizenSurveyOverview] = []
        var upcomingSurveyList: [SCModelCitizenSurveyOverview] = []

        for survey in surveyList {
            if Date().difference(from: survey.startDate) > 0 {
                upcomingSurveyList.append(survey)
            } else {
                if survey.daysLeft > 0 {
                    ongoingSurveyList.append(survey)
                } else if survey.daysLeft == 0 {
                    completedSurveyList.append(survey)
                }
            }
        }
        
        if !ongoingSurveyList.isEmpty {
            surveyDataDict[0] = SCCitizenSurveyDataSoureModel(surveyList: ongoingSurveyList,
                                                              sectionTitle: LocalizationKeys.SCCitizenSurveyOverviewTableViewDataSource.cs002RunningListHeader.localized())
        }

        if ongoingSurveyList.isEmpty && !upcomingSurveyList.isEmpty {
            surveyDataDict[0] = SCCitizenSurveyDataSoureModel(surveyList: ongoingSurveyList,
                                                              sectionTitle: LocalizationKeys.SCCitizenSurveyOverviewTableViewDataSource.cs002RunningListHeader.localized())
            surveyDataDict[1] = SCCitizenSurveyDataSoureModel(surveyList: upcomingSurveyList,
                                                              sectionTitle: LocalizationKeys.SCCitizenSurveyOverviewTableViewDataSource.cs002UpcomingListHeader.localized())
            
        } else if !upcomingSurveyList.isEmpty {
            surveyDataDict[1] = SCCitizenSurveyDataSoureModel(surveyList: upcomingSurveyList,
                                                              sectionTitle: LocalizationKeys.SCCitizenSurveyOverviewTableViewDataSource.cs002UpcomingListHeader.localized())
        }
        
        if !completedSurveyList.isEmpty {
            surveyDataDict[surveyDataDict.count] = SCCitizenSurveyDataSoureModel(surveyList: completedSurveyList,
                                                                                 sectionTitle: LocalizationKeys.SCCitizenSurveyOverviewTableViewDataSource.cs002ClosedListHeader.localized())
        }
    }
}

class SCCitizenSurveyOverviewTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    private var surveyList: [SCModelCitizenSurveyOverview]
    private var surveyListDataSource: SCCitizenSurveyDataSource
    private weak var delegate: SCCitizenSurveyOverviewDelegate?

    init(surveyList: [SCModelCitizenSurveyOverview],
         delegate: SCCitizenSurveyOverviewDelegate?) {
        self.surveyList = surveyList
        surveyListDataSource = SCCitizenSurveyDataSource(surveyList: surveyList)
        self.delegate = delegate
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return surveyListDataSource.surveyDataDict.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyListDataSource.surveyDataDict[section]?.surveyList.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SCCitizenSurveyOverviewTableViewCell.self),
                                                       for: indexPath) as? SCCitizenSurveyOverviewTableViewCell else {
            return UITableViewCell()
        }

        if let _surveyList = surveyListDataSource.surveyDataDict[indexPath.section]?.surveyList,
           _surveyList.count > indexPath.row {
            let survey = _surveyList[indexPath.row]
            cell.set(survey: survey)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _surveyList = surveyListDataSource.surveyDataDict[indexPath.section]?.surveyList, _surveyList.count > indexPath.row {
            if !(Date().difference(from: _surveyList[indexPath.row].startDate) > 0) {
                if (_surveyList[indexPath.row].daysLeft != 0) {
                    delegate?.selected(survey: _surveyList[indexPath.row])
                }
            } else if (Date().difference(from: _surveyList[indexPath.row].startDate) > 0) && isPreviewMode { // to view upcoming survey only in preview mode
                delegate?.selected(survey: _surveyList[indexPath.row])
            }
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = self.setupSurveyHeaderFooterView(surveyListDataSource.surveyDataDict[section]?.sectionTitle,
                                                    backgroundColor: .coolGray,
                                                    font: UIFont.SystemFont.bold.forTextStyle(style: .body, size: 18, maxSize: 28),
                                                    textAlignment: .left,
                                                    isHeader: true)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let view = self.setupSurveyHeaderFooterView(LocalizationKeys.SCCitizenSurveyOverviewTableViewDataSource.cs002ErrorNoRunningSurveys.localized(), 
                                                    backgroundColor: UIColor(named: "CLR_CELL_BACKGRND")!,
                                                    font: UIFont.SystemFont.regular.forTextStyle(style: .body, size: 16, maxSize: 24),
                                                    textAlignment: .center,
                                                    isHeader: false,
                                                    textColor: UIColor.labelTextBlackCLR)
        return surveyListDataSource.surveyDataDict[section]?.surveyList.count == 0 ? view : nil
    }

    func setupSurveyHeaderFooterView(_ title: String?, backgroundColor: UIColor, font: UIFont, textAlignment: NSTextAlignment, isHeader: Bool, textColor: UIColor = .black) -> UIView{
        
        let title = title
        let view = UIView()
        view.backgroundColor = backgroundColor
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = textAlignment
        
        let lineView = UIView()
        lineView.backgroundColor = .seperatorCLR
        lineView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(lineView)
        view.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        lineView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true

        view.layoutIfNeeded()

        label.accessibilityElementsHidden = true
        lineView.accessibilityElementsHidden = true

        view.isAccessibilityElement = true
        view.accessibilityElementsHidden = false
        view.accessibilityLabel = title
        view.accessibilityTraits = isHeader ? .header : .staticText
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return surveyListDataSource.surveyDataDict[section]?.surveyList.count == 0 ? 55 : 0
    }

    func updateDataSource(with surveys: [SCModelCitizenSurveyOverview]) {
        surveyListDataSource = SCCitizenSurveyDataSource(surveyList: surveys)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
