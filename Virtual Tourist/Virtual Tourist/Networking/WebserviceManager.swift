//
//  WebserviceManager.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/17/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class WebserviceManager {
    
    let appKey = "563a0ba1ecca7d07bc9b41c396710282"
   
    func searchForPhotos(latitude:Double, longitude:Double, page:Int,completion:@escaping(_ success: Bool, _ result:PhotosEntityWrapper?) -> Void) ->Void {
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(appKey)&lat=\(latitude)&lon=\(longitude)&accuracy=1&format=json&nojsoncallback=1&page=\(page)&per_page=27&extras=url_m"
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if response.data != nil {
                let decoder = JSONDecoder()
                
                guard (response.response?.statusCode == 200 || response.response?.statusCode == 204) else {
                    if response.response != nil {
                    }
                    completion(false, nil)
                    return
                }
                
                do {
                    let responseObject = try decoder.decode(PhotosEntityWrapper.self, from: response.data!)
                    completion(true,responseObject)
                } catch {
                    print(error.localizedDescription)
                    completion(false,nil)
                }
                
            } else {
                completion(false,nil)
            }
        }
    }
    
    func loadImage(imageUrl:String, completion:@escaping(_ success: Bool, _ result:Image?) -> Void) ->Void {
        Alamofire.request(imageUrl).responseImage { response in
            if response.data != nil {
                guard (response.response?.statusCode == 200 || response.response?.statusCode == 204) else {
                    if response.response != nil {
                    }
                    completion(false, nil)
                    return
                }
                if let image = response.result.value {
                    completion(true,image)
                }
            }
        }
    }
}



