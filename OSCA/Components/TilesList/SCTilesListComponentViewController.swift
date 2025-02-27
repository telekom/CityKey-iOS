/*
Created by Michael on 16.11.18.
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
 * SCTilesListComponentViewControllerDelegate is the protocol reference for
 * the SCTilesListComponentViewController delegate.
 *
 */
protocol SCTilesListComponentViewControllerDelegate : NSObjectProtocol
{
    func didSelectTilesListItem(item: SCBaseComponentItem, component: SCTilesListComponentViewController)
    func didPressDeleteBtnForItem(item: SCBaseComponentItem, component: SCTilesListComponentViewController)

    func switchedToDeleteMode(component: SCTilesListComponentViewController)
    func switchedToSelectMode(component: SCTilesListComponentViewController)
}

/**
 * SCTilesListCollectionViewCellDelegate is only used inside this component
 * to handle touch events of the tiles
 *
 */
protocol SCTilesListCollectionViewCellDelegate : NSObjectProtocol
{
    func didSelectTilesListItem(item: SCBaseComponentItem)
    func didPressDeleteBtnForItem(item: SCBaseComponentItem)
}

/**
 * Deletable is only used inside this component
 * to the methods for the delete functionality
 *
 */
protocol SCDeletableTilesListCollectionViewCell : NSObjectProtocol
{
    func showDeleteBtn(visible : Bool)
}

/**
 * @brief SCTilesListComponentViewController is an UI component
 *
 * SCTilesListComponentViewController shows tiles in an TilesList. The Items
 * can be set with property items which should be an array of SCBaseComponentItem.
 * The color of the tiles can be changed with the itemColor property of the SCBaseComponentItem .
 * To get an event when the user is tapping on the tile or a button, you can
 * set the delegate.
 */
class SCTilesListComponentViewController: UIViewController
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var items = [SCBaseComponentItem]()
    
    var cellWidth : CGFloat = 0.0
    var cellHeight : CGFloat = 0.0

    let cellScaling: CGFloat = 0.6
    weak var delegate:SCTilesListComponentViewControllerDelegate?

    private var deleteModeEnabled : Bool = false

    
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            self?.collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        let inset = GlobalConstants.kTilesListContentOffset
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumInteritemSpacing = GlobalConstants.kTilesListContentSpacerHorizontal
        layout.minimumLineSpacing = GlobalConstants.kTilesListContentSpacerVertical
        collectionView?.contentInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }


    func update(cellSize : CGSize) {
        self.cellWidth = cellSize.width -  GlobalConstants.kTilesListShadowSafeArea
        self.cellHeight = cellSize.height -  GlobalConstants.kTilesListShadowSafeArea
        self.collectionView?.collectionViewLayout.invalidateLayout()
        self.view.setNeedsLayout()
    }
    
    func update(itemList : [SCBaseComponentItem]?) {
        if (!self.deleteModeEnabled){
            self.items = itemList ?? []
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.cancelDeleteMode()
        } else {
            let oldItems = self.items
            let newItemList = itemList ?? []
            
            for oldItem in oldItems {
                var itemFound = false
                for currentItem in newItemList {
                    if oldItem.itemID == currentItem.itemID {
                        itemFound = true
                    }
                }
                if !itemFound {
                    self.delete(item: oldItem)
                }
            }
        }
     }
    
    func delete(item : SCBaseComponentItem) {
        
        var itemFoundAtPosition = -1
        var i = 0
        var newItemList =  [SCBaseComponentItem]()
        
        for currentItem in self.items {
            if currentItem.itemID != item.itemID {
                newItemList.append(currentItem)
            } else {
                itemFoundAtPosition = i
            }
            i += 1
        }
        
        if itemFoundAtPosition >= 0{
            self.items = newItemList
            let deleteIndexPath = NSIndexPath(item: itemFoundAtPosition, section: 0)
            self.collectionView?.performBatchUpdates({
            self.collectionView?.deleteItems(at: [deleteIndexPath as IndexPath]) })
        }
    }

    func scrollToFirstItem(animated: Bool) {
        if items.count > 0{
            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                              at: .left,
                                              animated: animated)
        }
    }
    
    func estimatedContentHeight(for columnsCount : Int) -> CGFloat{
        
        let yushu : Int = self.items.count % columnsCount;
        let shang : Int = Int(self.items.count / columnsCount);
        var lineNum = 0
        
        if (yushu == 0) {
            lineNum = shang;
        } else {
            lineNum = shang + 1
        }
        
        let totalCellHeight = CGFloat(cellHeight)
        
        let height : CGFloat = CGFloat(totalCellHeight * CGFloat(lineNum) + GlobalConstants.kTilesListContentSpacerVertical * (CGFloat(lineNum) ) )
        
        return height + 10.0
    }
    
    func startDeleteMode(){
        if !self.isDeleteModeStarted() {
            self.deleteModeEnabled = true
            self.collectionView?.startWiggle()
            self.delegate?.switchedToDeleteMode(component: self)
            for cell  in self.collectionView!.visibleCells{
                if let deletableCell = cell as? SCDeletableTilesListCollectionViewCell{
                    deletableCell.showDeleteBtn(visible : true)
                }
            }

        }
    }

    func isDeleteModeStarted() -> Bool{
        return self.deleteModeEnabled
    }

    func cancelDeleteMode() {
        if self.isDeleteModeStarted() {
            self.deleteModeEnabled = false
            self.collectionView?.stopWiggle()
            self.delegate?.switchedToSelectMode(component: self)
            for cell  in self.collectionView!.visibleCells{
                if let deletableCell = cell as? SCDeletableTilesListCollectionViewCell{
                    deletableCell.showDeleteBtn(visible : false)
                }
            }
        }
    }

}


/**
 * This Extension handles the touch events from the tiles and sends them to the
 * SCTilesListComponentViewController delegate
 */
extension SCTilesListComponentViewController : SCTilesListCollectionViewCellDelegate
{
    func didSelectTilesListItem(item: SCBaseComponentItem) {
        if !self.isDeleteModeStarted(){
            // we will only then the select event if we are not
            // in the deleting mode
            self.delegate?.didSelectTilesListItem(item: item, component: self)
        }
    }

    func didPressDeleteBtnForItem(item: SCBaseComponentItem) {
        self.delegate?.didPressDeleteBtnForItem(item: item, component: self)
    }
    
}

/**
 * This Extension implements the data source of the UICollectionViewController
 * and fills it with the item data
 */
extension SCTilesListComponentViewController : UICollectionViewDataSource
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
        case .tiles_icon:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TilesListIconComponentCell", for: indexPath) as! SCTilesListIconCollectionViewCell
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = items[indexPath.item].itemTitle
            cell.accessibilityTraits = .button
            cell.accessibilityHint = "accessibility_cell_dbl_click_hint".localized()
            cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            cell.content = self.items[indexPath.item]
            cell.delegate = self
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TilesListSmallComponentCell", for: indexPath) as! SCTilesListSmallCollectionViewCell
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = items[indexPath.item].itemTitle
            cell.accessibilityTraits = .button
            cell.accessibilityHint = "accessibility_cell_dbl_click_hint".localized()
            cell.accessibilityLanguage = SCUtilities.preferredContentLanguage()
            cell.content = self.items[indexPath.item]
            cell.delegate = self
            return cell
        }
        
    }
}
