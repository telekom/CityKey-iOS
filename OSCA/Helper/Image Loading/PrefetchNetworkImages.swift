//
//  PrefetchNetworkImages.swift
//  OSCA
//
//  Created by A118572539 on 01/04/22.
//  Copyright © 2022 Deutsche Telekom AG - VTI Organization. All rights reserved.
//

import Foundation
import Kingfisher

class PrefetchNetworkImages {

    static func prefetchImagesFromNetwork(with urls: [URL]) {
        ImagePrefetcher(urls: urls).start()
    }
}
