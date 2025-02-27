/*
Created by Michael on 22.11.18.
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
