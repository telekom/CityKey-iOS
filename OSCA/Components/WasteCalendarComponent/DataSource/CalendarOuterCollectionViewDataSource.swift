//
//  CalendarOuterCollectionViewDataSource.swift
//  Calendar
//
//  Created by Rutvik Kanbargi on 18/08/20.
//  Copyright © 2020 Rutvik Kanbargi. All rights reserved.
//

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
