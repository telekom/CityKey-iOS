//
//  CalendarOuterCollectionViewCell.swift
//  Calendar
//
//  Created by Rutvik Kanbargi on 18/08/20.
//  Copyright © 2020 Rutvik Kanbargi. All rights reserved.
//

import UIKit

class CalendarOuterCollectionViewCell: UICollectionViewCell {

    private weak var delegate: CalendarOuterCollectionViewDelgate?
    private let leftRightPadding : CGFloat = 21.0
    private var selectedDateHash: Int?

    private let innerCollectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor =  UIColor(named: "CLR_BCKGRND")!
        collectionView.isPrefetchingEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.delaysContentTouches = false
        return collectionView
    }()

    private var calenderDays: [SCCalendarDate] = []

    func setupViews() {
        self.addSubview(innerCollectionView)
        innerCollectionView.delegate = self
        innerCollectionView.dataSource = self
        innerCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        innerCollectionView.rightAnchor.constraint(equalTo:  self.rightAnchor).isActive = true
        innerCollectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        innerCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        register()
    }

    private func register() {
        let cellID = String(describing: CalendarInnerCollectionViewCell.self)
        let nib = UINib(nibName: cellID, bundle: nil)
        innerCollectionView.register(nib, forCellWithReuseIdentifier: cellID)
    }

    func set(calenderDays: [SCCalendarDate],
             selectedDateHash: Int?,
             delegate: CalendarOuterCollectionViewDelgate?) {
        setupViews()
        self.calenderDays = calenderDays
        self.delegate = delegate
        self.selectedDateHash = selectedDateHash
        let selectedCell = innerCollectionView.indexPathsForSelectedItems
        innerCollectionView.reloadData()
        innerCollectionView.selectItem(at: selectedCell?.first, animated: false, scrollPosition: .centeredHorizontally)
    }
}

extension CalendarOuterCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calenderDays.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarInnerCollectionViewCell.self), for: indexPath) as! CalendarInnerCollectionViewCell
        let calendarDay = calenderDays[indexPath.item]
        cell.set(data: calendarDay, selectedDateHash: selectedDateHash)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - (2*leftRightPadding)) / 7
        return CGSize(width: width, height: width - 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let calendarDate = calenderDays[indexPath.item]
        if calendarDate.type.isSelectable() {
            delegate?.didSelect(day: calendarDate, selectedDateHash: selectedDateHash)
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarInnerCollectionViewCell else {
            return
        }
        cell.containerView.backgroundColor = kColor_cityColor

        UIView.animate(withDuration: 0.1, delay: 0.0, options: .allowUserInteraction, animations: {
            cell.containerView.backgroundColor = kColor_cityColor
        }, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarInnerCollectionViewCell else {
            return
        }

        UIView.animate(withDuration: 0.1, delay: 0.0, options: .allowUserInteraction, animations: {
            [weak self] in
            cell.containerView.backgroundColor = self?.calenderDays[indexPath.item].type.getDeSelectedBackgroundColor()
        }, completion: nil)
    }
}
