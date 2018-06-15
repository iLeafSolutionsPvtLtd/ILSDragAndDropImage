//
//  ILSImageSliderCollectionViewCell.swift
//  ILSImageSlider
//
//  Created by Rupesh on 6/14/18.
//  Copyright © 2018 Sharon. All rights reserved.
//

import UIKit
import Photos


    public let FAImagePlaceHolderSize: CGSize = CGSize(width: 100.0, height: 100.0)
    
    
   class ILSImageSliderCollectionViewCell: UICollectionViewCell {
        
        //  MARK: IBOutlets
        
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var selectionView: UIView!
        @IBOutlet weak var selectionView: UIView!
        @IBOutlet weak var imageView: UIImageView!
    
        // MARK: Class Properties
        
        var longPressGestrue: UILongPressGestureRecognizer!
        
        override var isSelected:Bool{
            
            didSet{
                if isSelected {
                    selectionView.backgroundColor = .gray
                }
                else{
                    selectionView.backgroundColor = .clear
                }
            }
}
    

    //  MARK: Functions
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if self.imageView != nil{
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewConfigurations()
    }
    
    private func viewConfigurations(){
        selectionView.layer.borderWidth = 2
        selectionView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func populateDataWith(asset:PHAsset) {
        
        ImageLoader.imageFrom(asset: asset, size: FAImagePlaceHolderSize) { (image) in
            DispatchQueue.main.async {
                if self.imageView != nil{
                    self.imageView.image = image
                }
            }
        }
    }
    
    func configureGestureWithTarget(target: Any?, action: Selector?) {
        
        longPressGestrue = UILongPressGestureRecognizer(target: target, action: action)
        longPressGestrue.minimumPressDuration = 0.25
        self.addGestureRecognizer(longPressGestrue)
    }
    
}


