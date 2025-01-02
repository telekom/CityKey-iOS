//
//  SCBaseCollectionViewCell.swift
//  SmartCity
//
//  Created by Michael on 22.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

class SCBaseCollectionViewCell: UICollectionViewCell,SCDeletableTilesListCollectionViewCell {
    
    var deleteButton : UIButton!

    var tapGesture : UITapGestureRecognizer?
    
    
    weak var delegate : SCTilesListCollectionViewCellDelegate?
    
    var content: SCBaseComponentItem? {
        didSet {
            self.showDeleteBtn(visible : false)
            self.updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self .addDeleteButton()
    }
    
    private func addDeleteButton(){
        let deleteButtonSize: CGFloat = 25
        
        self.deleteButton = UIButton()
        self.deleteButton.backgroundColor = UIColor.lightGray
        self.deleteButton.layer.cornerRadius = deleteButtonSize / 2.0
        self.deleteButton.addTarget(self, action:#selector(self.deleteWasPressed), for: .touchUpInside)
        self.deleteButton.setTitle("X", for: .normal)
        self.deleteButton.setTitleColor(UIColor(named: "CLR_LABEL_TEXT_BLACK")!, for: .normal)
 
        self.addSubview(self.deleteButton)
        
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: self.deleteButton as Any, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: deleteButtonSize).isActive = true
        NSLayoutConstraint(item: self.deleteButton as Any, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: deleteButtonSize).isActive = true
        
        NSLayoutConstraint(item: self.deleteButton as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: deleteButtonSize * 0.2).isActive = true
        NSLayoutConstraint(item: self.deleteButton as Any, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: deleteButtonSize * 0.2).isActive = true
        
        self.deleteButton.isHidden = true
    }
    
    func showDeleteBtn(visible : Bool){
        self.deleteButton.isHidden = !visible
    }
    


    func updateUI(){
    }

    
    @objc func teaserWasPressed() {
        if let item = content {
            self.delegate?.didSelectTilesListItem(item: item)
        }
    }
    
    @objc func deleteWasPressed() {
        if let item = content {
            self.delegate?.didPressDeleteBtnForItem(item: item)
        }
    }

}
