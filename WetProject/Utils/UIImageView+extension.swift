//
//  UIImageView+extension.swift
//  WetProject
//
//  Created by 남오승 on 2020/10/23.
//

import UIKit

// Global variable or stored in a singleton / top level object (Ex: AppCoordinator, AppDelegate)
let imageCache = NSCache<NSString, UIImage>()

//이미지 캐싱을 위한 UIImageView 확장파일
extension UIImageView {

    func downloadImage(from imgURL: String) -> URLSessionDataTask? {
        guard let url = URL(string: imgURL) else { return nil }

        // set initial image to nil so it doesn't use the image from a reused cell
        image = nil

        // check if the image is already in the cache
        if let imageToCache = imageCache.object(forKey: imgURL as NSString) {
            self.image = imageToCache
            return nil
        }

        // download the image asynchronously
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print(err)
                return
            }

            DispatchQueue.main.async {
                // create UIImage
                guard let setData = data else {
                      return
                }
    
                if let imageToCache = UIImage(data: setData) {
                    // add image to cache
                    imageCache.setObject(imageToCache, forKey: imgURL as NSString)
                    self.image = imageToCache
                }
                
            }
        }
        task.resume()
        return task
    }
}
