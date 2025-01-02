//
//  UIImageView+Load.swift
//  SmartCity
//
//  Created by Michael on 31.10.18.
//  Copyright © 2018 Michael. All rights reserved.
//

import UIKit

/**
 *
 * Support extension für the Image view for caching
 * and lazy loading
 *
 */

private let INDICATOR_VIEW_TAG = 999
private var imageUrl: SCImageURL? = nil // the address of key is a unique id.

extension UIImageView  {
    
    var lastImageUrl: SCImageURL? {
        get { return objc_getAssociatedObject(self, &imageUrl) as? SCImageURL}
        set { objc_setAssociatedObject(self, &imageUrl, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    func load(from url:SCImageURL?) {
        if url != nil {
            
            if lastImageUrl != nil && lastImageUrl != url {
                SCImageLoader.sharedInstance.cancelImageRequest(for: lastImageUrl!)
            }
            
            self.image = nil
            self.lastImageUrl = url
            SCImageLoader.sharedInstance.getImage(with: url!, completion:{[weak self]
                (_ image: UIImage?, _ error:SCImageLoaderError?) in
                
                if image != nil{
                    self?.image = image
                }
            })
        } else {
            self.image = nil
        }
    }
    
    // SMARTC-18942 : Wrong icon and Background tiles not loading
    func loadServiceBGImage(from url:SCImageURL?) {
        if url != nil {
            self.image = nil
            self.lastImageUrl = url
            SCImageLoader.sharedInstance.getImage(with: url!, completion:{[weak self]
                (_ image: UIImage?, _ error:SCImageLoaderError?) in
                
                if image != nil && self?.lastImageUrl == url {
                    self?.image = image
                }
            })
        } else {
            self.image = nil
        }
    }
    
    func load(from url:SCImageURL?, maxWidth: CGFloat) {
        if url != nil {
                self.image = nil
                self.lastImageUrl = url
            
                SCImageLoader.sharedInstance.getImage(with: url!, completion:{[weak self]
                    (_ image: UIImage?, _ error:SCImageLoaderError?) in
                    
                    if image != nil && self?.lastImageUrl == url {
                        let smallImage = image?.resizedImageWithinRect(rectSize: CGSize(width: maxWidth, height: 9999.0), withScale: true)

                        self?.image = smallImage
                    }
                })
        } else {
            self.image = nil
        }
    }
    
    func load(from url:SCImageURL?, maskColor: UIColor) {
        if url != nil {
                self.image = nil
                SCImageLoader.sharedInstance.getImage(with: url!, completion:{[weak self]
                    (_ image: UIImage?, _ error:SCImageLoaderError?) in
                    
                    if image != nil{
                        self?.image = image?.maskWithColor(color: maskColor)
                    }
                })
        } else {
                   self.image = nil
        }
    }
    
    func loadIconImage(from url:SCImageURL?, maskColor: UIColor) {
        if url != nil {
            self.image = nil
            self.lastImageUrl = url
            SCImageLoader.sharedInstance.getImage(with: url!, completion:{[weak self]
                (_ image: UIImage?, _ error:SCImageLoaderError?) in
                
                if image != nil && self?.lastImageUrl == url {
                    self?.image = image?.maskWithColor(color: maskColor)
                }
            })
        } else {
            self.image = nil
        }
    }
    func load(from url:SCImageURL?, maxWidth: CGFloat, completion: @escaping (Bool) -> Void) {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.tag = INDICATOR_VIEW_TAG
        
        if url != nil {
            if lastImageUrl != nil && lastImageUrl != url {
                let indicatorView = viewWithTag(INDICATOR_VIEW_TAG)
                indicatorView?.removeFromSuperview()
                SCImageLoader.sharedInstance.cancelImageRequest(for: lastImageUrl!)
            }

            self.image = nil
            self.lastImageUrl = url
            
            if #available(iOS 13.0, *) {
              activityIndicator.style = .medium
            } else {
                activityIndicator.style = .gray
            }
            addSubview(activityIndicator)
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false

            let centerX = NSLayoutConstraint(item: self,
                                             attribute: .centerX,
                                             relatedBy: .equal,
                                             toItem: activityIndicator,
                                             attribute: .centerX,
                                             multiplier: 1,
                                             constant: 0)
            let centerY = NSLayoutConstraint(item: self,
                                             attribute: .centerY,
                                             relatedBy: .equal,
                                             toItem: activityIndicator,
                                             attribute: .centerY,
                                             multiplier: 1,
                                             constant: 0)
            self.addConstraints([centerX, centerY])
            
            SCImageLoader.sharedInstance.getImage(with: url!, completion:{[weak self]
                (_ image: UIImage?, _ error:SCImageLoaderError?) in
                
                if image != nil{
                    let smallImage = image?.resizedImageWithinRect(rectSize: CGSize(width: maxWidth, height: 9999.0), withScale: true)

                    self?.image = smallImage
                    activityIndicator.removeFromSuperview()

                    completion(true)

                }else{
                    activityIndicator.removeFromSuperview()
                    completion(false)
                }
            })
        } else {
            self.image = nil
            activityIndicator.removeFromSuperview()
            completion(false)
        }
    }

}
