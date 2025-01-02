//
//  SCCarouselComponentViewController.swift
//  SmartCity
//
//  Created by Michael on 14.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
