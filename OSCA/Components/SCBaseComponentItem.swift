//
//  SCBaseComponentItem.swift
//  SmartCity
//
//  Created by Michael on 19.12.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 * Data item for the tiles in the SCCarouselComponentViewController
 *
 * @param itemID
 *            unique id of the city
 * @param itemTitle
 *            a short title presented on the tile
 * @param itemTeaser
 *            a teaser text presented on the tile
 * @param imageURL
 *            url for the tile image
 * @param itemURL
 *            url to the detailed content
 * @param itemDetail
 *            detail content
 * @param itemHtmlDetail
 *            is detail content plain or html
 * @param itemCategoryTitle
 *            title for the category. this won't be presented by the tile but on the
 *            content detail screen in the top navigation bar
 * @param itemColor
 *            color fot the tile background
 * @param itemCellType
 *            defines ui layout of the tiles
 * @param itemLockedDueAuth
 *            if true the item can only used by an authorized user
 * @param itemLockedDueResidence
 *            if true the item can only used by a resident of the city
 * @param itemIsNew
 *            if true the item is new  added
 * @param itemFunction
 *            conatibs any informnations or ids for functions on this service
 * @param itemBtnActions
 *            context informationfor the button sactions
 * @param itemContext
 *            context information, needed for UI and technical purposes.
 */

enum SCBaseComponentItemCellType {
    case carousel_big
    case carousel_small
    case carousel_iconSmallText
    case carousel_iconBigText
    case tiles_icon
    case tiles_small
    case not_specified
}

enum SCBaseComponentItemContext {
    case favorites
    case overview
    case none
}

enum SCComponentDetailBtnType: Equatable {
    case cityColorFull
    case cityColorLight
}

struct SCComponentDetailBtnAction: Equatable {
    static func == (lhs: SCComponentDetailBtnAction, rhs: SCComponentDetailBtnAction) -> Bool {
        return lhs.title == rhs.title &&
        lhs.btnType == rhs.btnType &&
        lhs.modelServiceAction == rhs.modelServiceAction
    }
    
    let title : String
    let btnType : SCComponentDetailBtnType
    let modelServiceAction : SCModelServiceAction?
    let completion: (() -> Void)
}

struct SCBaseComponentItem: Equatable {

    static func == (lhs: SCBaseComponentItem, rhs: SCBaseComponentItem) -> Bool {
        return lhs.itemID == rhs.itemID &&
        lhs.itemTitle == rhs.itemTitle &&
        lhs.itemTeaser == rhs.itemTeaser &&
        lhs.itemSubtitle == rhs.itemSubtitle &&
        lhs.itemImageURL == rhs.itemImageURL &&
        lhs.itemImageCredit == rhs.itemImageCredit &&
        lhs.itemThumbnailURL == rhs.itemThumbnailURL &&
        lhs.itemIconURL == rhs.itemIconURL &&
        lhs.itemURL == rhs.itemURL &&
        lhs.itemDetail == rhs.itemDetail &&
        lhs.itemHtmlDetail == rhs.itemHtmlDetail &&
        lhs.itemCategoryTitle == rhs.itemCategoryTitle &&
        lhs.itemColor == rhs.itemColor &&
        lhs.itemCellType == rhs.itemCellType &&
        lhs.itemLockedDueAuth == rhs.itemLockedDueAuth &&
        lhs.itemLockedDueResidence == rhs.itemLockedDueResidence &&
        lhs.itemIsNew == rhs.itemIsNew &&
        lhs.itemFunction == rhs.itemFunction &&
        lhs.itemBtnActions == rhs.itemBtnActions &&
        lhs.itemContext == rhs.itemContext &&
        lhs.badgeCount == rhs.badgeCount &&
        lhs.itemServiceParams == rhs.itemServiceParams &&
        lhs.helpLinkTitle == rhs.helpLinkTitle &&
        lhs.templateId == rhs.templateId &&
        lhs.headerImageURL == rhs.headerImageURL &&
        lhs.serviceType == rhs.serviceType
    }

    var itemID : String
    var itemTitle : String
    var itemTeaser : String?
    var itemSubtitle : String?
    var itemImageURL : SCImageURL?
    var itemImageCredit : String?
    var itemThumbnailURL : SCImageURL?
    var itemIconURL: SCImageURL?
    var itemURL : URL?
    var itemDetail : String?
    var itemHtmlDetail : Bool
    var itemCategoryTitle : String?
    var itemColor : UIColor
    var itemCellType : SCBaseComponentItemCellType = .not_specified
    var itemLockedDueAuth : Bool = false
    var itemLockedDueResidence : Bool = false
    var itemIsNew : Bool = false
    var itemFunction : String?
    var itemBtnActions : [SCComponentDetailBtnAction]?
    var itemContext : SCBaseComponentItemContext = .none
    var badgeCount: Int?
    var itemServiceParams : [String:String]?
    var helpLinkTitle: String?
    var templateId: Int?
    var headerImageURL: SCImageURL?
    var serviceType: String?

}
