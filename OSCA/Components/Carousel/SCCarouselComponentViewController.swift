/*
Created by Michael on 14.10.18.
Copyright © 2018 Michael. All rights reserved.

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

SPDX-FileCopyrightText: 2025 Deutsche Telekom AG, Copyright © 2018 Michael
SPDX-License-Identifier: Apache-2.0 AND LicenseRef-Deutsche-Telekom-Brand
License-Filename: LICENSES/Apache-2.0.txt LICENSES/LicenseRef-Deutsche-Telekom-Brand.txt
*/

import UIKit

/**
 * SCCarouselComponentViewControllerDelegate is the protocol reference for
 * the SCCarouselComponentViewController delegate.
 *
*/
protocol SCCarouselComponentViewControllerDelegate : NSObjectProtocol
{
    func didSelectCarouselItem(item: SCBaseComponentItem)
}

/**
 * SCCarouselCollectionViewCellDelegate is only used inside this component
 * to handle touch events of the tiles
 *
 */
protocol SCCarouselCollectionViewCellDelegate : NSObjectProtocol
{
    func didSelectCarouselItem(item: SCBaseComponentItem)
}

/**
 * @brief SCCarouselComponentViewController is an UI component
 *
 * SCCarouselComponentViewController shows tiles in an carousel. The Items
 * can be set with property items which should be an array of SCBaseComponentItem.
 * The color of the tiles can be changed with the itemColor property of the SCBaseComponentItem .
 * To get an event when the user is tapping on the tile or a button, you can
 * set the delegate.
 */
class SCCarouselComponentViewController: UIViewController
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var items = [SCBaseComponentItem]()

    var cellWidth : CGFloat = 0.0
    var cellHeight : CGFloat = 0.0

    let cellScaling: CGFloat = 0.6
    weak var delegate:SCCarouselComponentViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = self
        collectionView?.isPagingEnabled = false
        collectionView?.backgroundColor = .clear
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        //collectionView?.bounces = false
        self.collectionView?.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        let inset = GlobalConstants.kCarouselContentOffset
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth - inset, height: cellHeight - inset)
        layout.minimumInteritemSpacing = GlobalConstants.kCarouselContentSpacer
        layout.minimumLineSpacing = GlobalConstants.kCarouselContentSpacer
        collectionView?.contentInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
        
    func update(cellSize : CGSize) {
        self.cellWidth = cellSize.width -  GlobalConstants.kCarouselShadowSafeArea
        self.cellHeight = cellSize.height -  GlobalConstants.kCarouselShadowSafeArea
        self.collectionView?.collectionViewLayout.invalidateLayout()
        self.view.setNeedsLayout()
    }

    func update(itemList : [SCBaseComponentItem]?) {
        self.items = itemList ?? []
        self.collectionView?.reloadData()
        self.collectionView?.collectionViewLayout.invalidateLayout()
    }

    func scrollToFirstItem(animated: Bool) {
        if items.count > 0 {
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                              at: .left,
                                              animated: animated)
        }
    }
    
    func estimatedContentHeight() -> CGFloat{

        let height : CGFloat = CGFloat(self.cellHeight + GlobalConstants.kCarouselShadowSafeArea)
        
        return height + 10.0
    }

}


/**
 * This Extension handles the touch events from the tiles and sends them to the
 * SCCarouselComponentViewController delegate
 */
extension SCCarouselComponentViewController : SCCarouselCollectionViewCellDelegate
{
    func didSelectCarouselItem(item: SCBaseComponentItem) {
        self.delegate?.didSelectCarouselItem(item: item)
    }
    
}

/**
 * This Extension implements the data source of the UICollectionViewController
 * and fills it with the item data
 */
extension SCCarouselComponentViewController : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {

        switch self.items[indexPath.item].itemCellType {
        case .carousel_small:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselSmallComponentCell", for: indexPath) as! SCCarouselSmallCollectionViewCell
            cell.content = self.items[indexPath.item]
            cell.delegate = self
            return cell
        case .carousel_iconSmallText:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselIconComponentCell", for: indexPath) as! SCCarouselIconCollectionViewCell
            cell.content = self.items[indexPath.item]
            cell.delegate = self
            cell.interestTitleLabel.font = UIFont(name: cell.interestTitleLabel.font.fontName, size: 12.0)
            return cell
        case .carousel_iconBigText:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselIconComponentCell", for: indexPath) as! SCCarouselIconCollectionViewCell
            cell.content = self.items[indexPath.item]
            cell.delegate = self
            cell.interestTitleLabel.font = UIFont(name: cell.interestTitleLabel.font.fontName, size: 16.0)
            return cell
       default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarouselBigComponentCell", for: indexPath) as! SCCarouselBigCollectionViewCell
            cell.content = self.items[indexPath.item]
            cell.delegate = self
            return cell
        }
        
    }
}
