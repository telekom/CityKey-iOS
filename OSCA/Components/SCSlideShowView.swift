//
//  SCSlideShowView.swift
//  SmartCity
//
//  Created by Michael on 27.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

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
