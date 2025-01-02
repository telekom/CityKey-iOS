//
//  SCDefectReporterFormViewController+SCImagePickerDelegate.swift
//  OSCA
//
//  Created by Bhaskar N S on 21/07/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import UIKit

extension SCDefectReporterFormViewController: SCImagePickerDelegate {

    func didSelect(image: UIImage?) {
        
        if image != nil{
            
            image?.compressImageBelow(kb: 2000.0, completion: { (compressedImage, imageData) in
                
                guard let imgData = imageData else {
                  return
                }
                //Use compressedImage here or
                //Send img data in multiparts
                
                self.defectImageData = imgData
                self.defectPhotoImageView.image = image
                self.handleImageSelection(isDefectImageVisible: false, isAddPhotoBtnVisible: true, isDeletePhotoBtnVisible: false, addPhotoViewBorder: 0)
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                UIAccessibility.post(notification: .layoutChanged, argument: deletePhotoBtn)

            })
        }else{
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
        }
    }
    
    func cancelSelection() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.handleImageSelection(isDefectImageVisible: true, isAddPhotoBtnVisible: false, isDeletePhotoBtnVisible: true, addPhotoViewBorder: 1)
    }
}
