//
//  ImageLoader.swift
//  ILSImageSlider
//
//  Created by Rupesh on 6/14/18.
//  Copyright © 2018 Sharon. All rights reserved.
//

import Foundation
import Photos

typealias Success = (_ photos:[PHAsset])->Void

class ImageLoader: NSObject {
    
    private var assets = [PHAsset]()
    private var success:Success? = nil
    
    func loadPhotos(success:Success!){
        self.success = success
        loadAllPhotos()
    }
    
    private func loadAllPhotos() {
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        fetchResult.enumerateObjects({ (object, index, stop) -> Void in
            self.assets.append(object)
            if self.assets.count == fetchResult.count{ self.success!(self.assets) }
        })
    }
    
    static func imageFrom(asset:PHAsset, size:CGSize, success:@escaping (_ photo:UIImage)->Void){
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, attributes) in
            success(image!)
        })
    }
}
