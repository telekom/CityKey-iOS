/*
Created by Michael on 27.11.18.
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


protocol SCSlideShowViewDelegate : NSObjectProtocol
{
    func screenWillSwitch(to imageNr : Int)
}

class SCSlideShowView: UIView {
    
    let transformationFactor : CGFloat =  1.1
 
    var nextDisplayedImageindex = 0
    var parentView = UIView()
    var imagesList = [UIImageView]()

    var slideTimer: Timer!
    
    weak var delegate : SCSlideShowViewDelegate?

    init(frame: CGRect, parentView: UIView, images: [UIImage]){
        super.init(frame: frame)
        
        self.parentView = parentView
        var tagForImage = 0
        
        for image  in images {
            addImage(image, with: tagForImage, alpha: tagForImage == 0 ? 1.0 : 0.0)
            tagForImage += 1
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    private func addImage(_ image: UIImage, with tag:Int, alpha: Float){
        //create new UIimageView
        let imageView = UIImageView(frame: self.bounds)
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.center = self.center
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = CGFloat(alpha)
        imageView.isUserInteractionEnabled = false
        imageView.tag = tag
        imagesList.append(imageView)
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.addSubview(imageView)
        imageView.isHidden = true
        imageView.setNeedsLayout()
    }
    
    private func moveTo (imageView : UIImageView, pathLength : Double) -> CGPoint {
        
        let xCoord = imageView.center.x +  CGFloat(pathLength)
        let yCoord = imageView.center.y +  CGFloat(pathLength)
        
        return CGPoint(x: xCoord, y: yCoord)
    }
    
    private func getNextImageIndex() -> Int {
        nextDisplayedImageindex = (nextDisplayedImageindex + 1) % imagesList.count
        return nextDisplayedImageindex
    }

    private func getPreviousImageIndex() -> Int{
        nextDisplayedImageindex = (nextDisplayedImageindex + imagesList.count - 1) % imagesList.count
        return nextDisplayedImageindex
    }

    func startAnimation(){
        self.imagesList[ 0 ].transform = CGAffineTransform(scaleX: transformationFactor, y: transformationFactor)
        UIView.animate(
            withDuration: GlobalConstants.firstTimeUsageSwitchDuration + GlobalConstants.firstTimeUsagePresentDuration ,
            delay: 0.0,
            options: [.curveLinear],
            animations: { [weak self] () -> Void in
                guard let this = self else { return }
                this.imagesList[ 0 ].transform = CGAffineTransform(scaleX: 1.0, y: 1.0)}, completion: nil)
        self.startAnimationTimer()
    }

    func stopAnimation(){
        self.stopAnimationTimer()
    }

    
    private func startAnimationTimer(){
        self.slideTimer = Timer.scheduledTimer(timeInterval: GlobalConstants.firstTimeUsagePresentDuration, target: self, selector: #selector(switchNextImage), userInfo: nil, repeats: true)
    }

    private func stopAnimationTimer(){
        self.slideTimer.invalidate()
        self.slideTimer = nil
    }

   func switchToNext() {
//        self.stopAnimationTimer()
        self.animateImageViews(to: self.getNextImageIndex())
//        self.startAnimationTimer()
    }
    
    func switchToPrevious() {
//        self.stopAnimationTimer()
        self.animateImageViews(to: self.getPreviousImageIndex())
//        self.startAnimationTimer()
    }

    
    private func animateImageViews(to indexNr : Int){
        self.delegate?.screenWillSwitch(to: nextDisplayedImageindex)

        for imageView  in self.imagesList {
            imageView.frame = self.bounds
            imageView.center = self.center
            
        }
        self.imagesList[ indexNr ].transform = CGAffineTransform(scaleX: transformationFactor, y:transformationFactor)
        let imageview : UIImageView = self.imagesList[ indexNr ]
        self.bringSubviewToFront(imageview)

//        let displacrImageViewToPoint = moveTo(imageView: imagesList[indexNr ], pathLength: 0)
        
//        let firstAnimation = { [weak self] () -> Void in
//            guard let this = self else { return }
//
//            var i = 0
//            for imageView  in this.imagesList {
//
//                if (i != indexNr) {
//                    imageView.alpha = 0
//                }
//                i += 1
//            }
//
//        }
//
//        let SecondAnimation = { [weak self] () -> Void in
//            guard let this = self else { return }
//             this.imagesList[ indexNr ].alpha = 1 /////0
//        }
//
//        let ThirdAnimation = { [weak self] () -> Void in
//            guard let this = self else { return }
//            //make next displayed image that is second to top or second to last in array appear
//             this.imagesList[ indexNr ].transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
//
//            //moving the image while animating
//            this.imagesList[ indexNr ].center = displacrImageViewToPoint
//
//        }

//       UIView.animate(
//            withDuration: GlobalConstants.firstTimeUsageSwitchDuration / 2.0 ,
//            delay: GlobalConstants.firstTimeUsageSwitchDuration / 2.0,
//            options: [.curveLinear],
//            animations: firstAnimation, completion: nil)
//        
//        UIView.animate(
//            withDuration: GlobalConstants.firstTimeUsageSwitchDuration ,
//            delay: 0.0,
//            options: [.curveLinear],
//            animations: SecondAnimation, completion: nil)
//
//        UIView.animate(
//            withDuration: GlobalConstants.firstTimeUsageSwitchDuration + GlobalConstants.firstTimeUsagePresentDuration ,
//            delay: 0.0,
//            options: [.curveLinear],
//            animations: ThirdAnimation, completion: nil)

    }
    
    @objc private func switchNextImage() {
        self.animateImageViews(to: self.getNextImageIndex())
    }
    
}
