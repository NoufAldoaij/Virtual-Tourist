//
//  PhotosEntityWrapper.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/17/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.
//

import Foundation
//class PhotosEntityWrapper:Codable {
//    var stat: String?
//    var photos: PhotosEntity?
//}

class PhotosEntityWrapper:Codable {
    let stat: String?
    let photos: FlickrPhotos?
}
