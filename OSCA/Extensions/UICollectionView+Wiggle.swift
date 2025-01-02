//
//  UICollectionView+Wiggle.swift
//  SmartCity
//
//  Created by Michael on 21.11.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 *
 * This Extension adds a wiggling effect to the UICollection View
 *
 */

extension UICollectionView {
    func startWiggle() {
        for cell in self.visibleCells {
            addWiggleAnimationToCell(cell: cell as UICollectionViewCell)
        }
    }
    
    func stopWiggle() {
        for cell in self.visibleCells {
            cell.layer.removeAllAnimations()
        }
    }
        
    private func addWiggleAnimationToCell(cell: UICollectionViewCell) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        cell.layer.add(rotationAnimation(), forKey: "rotation")
        cell.layer.add(bounceAnimation(), forKey: "bounce")
        CATransaction.commit()
    }
    
    private func rotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let angle = CGFloat(0.02)
        let duration = TimeInterval(0.1)
        let variance = Double(0.012)
        animation.values = [angle, -angle]
        animation.autoreverses = true
        animation.duration = self.randomizeInterval(interval: duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    private func bounceAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        let bounce = CGFloat(1.0)
        let duration = TimeInterval(0.12)
        let variance = Double(0.012)
        animation.values = [bounce, -bounce]
        animation.autoreverses = true
        animation.duration = self.randomizeInterval(interval: duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    private func randomizeInterval(interval: TimeInterval, withVariance variance:Double) -> TimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random;
    }

}
