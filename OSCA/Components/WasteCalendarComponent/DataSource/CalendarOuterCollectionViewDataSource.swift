/*
Created by Rutvik Kanbargi on 18/08/20.
Copyright © 2020 Rutvik Kanbargi. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2020 Rutvik Kanbargi
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

protocol CalendarOuterCollectionViewDelgate: AnyObject {
    func didSelect(day: SCCalendarDate, selectedDateHash: Int?)
}

class CalendarOuterCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var calenderMonths: [[SCCalendarDate]]
    private var calenderMonthTitles: [String]
    private var calenderMonthValues: [Int]
    private weak var delegate: CalendarActionDelegate?
    private var selectedDateHash: Int?

    init(calenderMonths: [[SCCalendarDate]],
         calenderMonthTitles: [String],
         calenderMonthValues: [Int],
         delegate: CalendarActionDelegate?) {
        self.calenderMonths = calenderMonths
        self.calenderMonthTitles = calenderMonthTitles
        self.calenderMonthValues = calenderMonthValues
        self.delegate = delegate
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calenderMonths.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarOuterCollectionViewCell.self), for: indexPath) as! CalendarOuterCollectionViewCell
        cell.set(calenderDays: calenderMonths[indexPath.row], selectedDateHash: selectedDateHash, delegate: self)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width,
                      height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.willSwitchToMonth(name: calenderMonthTitles[indexPath.item], monthValue: calenderMonthValues[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.didSwitchToMonth()
        let visibleCellIndex = collectionView.indexPathsForVisibleItems.first
        delegate?.handleNextCalendarButtonInteraction(enabled: visibleCellIndex?.row != (calenderMonthTitles.count - 1))
        delegate?.handlePreviousCalendarButtonInteraction(enabled: visibleCellIndex?.row != 0)
    }
}

extension CalendarOuterCollectionViewDataSource: CalendarOuterCollectionViewDelgate {

    func didSelect(day: SCCalendarDate, selectedDateHash: Int?) {
        self.selectedDateHash = selectedDateHash
        delegate?.didSelectDay(date: day)
    }
}
