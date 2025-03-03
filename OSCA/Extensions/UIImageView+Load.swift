/*
Created by Michael on 31.10.18.
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
