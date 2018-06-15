//
//  ViewController.swift
//  ILSImageSlider
//
//  Created by Rupesh on 6/14/18.
//  Copyright © 2018 Sharon. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
        
        // MARK: IBOutlets
        @IBOutlet weak var scrollContainerView: UIView!
        @IBOutlet weak var scrollView: ILSScrollView!
        @IBOutlet weak var collectionView: UICollectionView!
        @IBOutlet weak var btnZoom: UIButton!
        @IBOutlet weak var btnCrop: UIButton!
        @IBAction func zoom(_ sender: Any) {
            scrollView.zoom()
        }
        @IBAction func crop(_ sender: Any) {
            croppedImage = captureVisibleRect()
           
              self.scrollView.imageToDisplay = croppedImage
         
        }
        
        
        // MARK: Public Properties
        
        var photos:[PHAsset]!
        var imageViewToDrag: UIImageView!
        var indexPathOfImageViewToDrag: IndexPath!
        
        let cellWidth = ((UIScreen.main.bounds.size.width)/3)-1
        
        
        // MARK: Private Properties
        
        private let imageLoader = ImageLoader()
        private var croppedImage: UIImage? = nil
        
        
        
        // MARK: LifeCycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.\
            viewConfigurations()
            checkForPhotosPermission()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        

        
        // MARK: Private Functions
        
        private func checkForPhotosPermission(){
            
            // Get the current authorization state.
            let status = PHPhotoLibrary.authorizationStatus()
            
            if (status == PHAuthorizationStatus.authorized) {
                // Access has been granted.
                loadPhotos()
            }
            else if (status == PHAuthorizationStatus.denied) {
                // Access has been denied.
            }
            else if (status == PHAuthorizationStatus.notDetermined) {
                
                // Access has not been determined.
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        
                        DispatchQueue.main.async {
                            self.loadPhotos()
                        }
                    }
                    else {
                        // Access has been denied.
                    }
                })
            }
                
            else if (status == PHAuthorizationStatus.restricted) {
                // Restricted access - normally won't happen.
            }
        }
        
        private func viewConfigurations() {
            
            navigationBarConfigurations()
            btnCrop.layer.cornerRadius = 5
            btnZoom.layer.cornerRadius = 5
        }
        
        private func navigationBarConfigurations() {
            
            navigationController?.navigationBar.backgroundColor = .black
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.setBackgroundImage(UIImage(color: .black), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage(color: .clear)
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        }
        
        
        private func loadPhotos(){
            
            imageLoader.loadPhotos { (assets) in
                self.configureImageCropper(assets: assets)
            }
        }
        
        private func configureImageCropper(assets:[PHAsset]){
            
            if assets.count != 0{
                photos = assets
                collectionView.delegate = self
                collectionView.dataSource = self
                collectionView.reloadData()
                selectDefaultImage()
            }
        }
        
        private func selectDefaultImage(){
            collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .top)
            selectImageFromAssetAtIndex(index: 0)
        }
        
        
        private func captureVisibleRect() -> UIImage{
            
            var croprect = CGRect.zero
            let xOffset = (scrollView.imageToDisplay?.size.width)! / scrollView.contentSize.width;
            let yOffset = (scrollView.imageToDisplay?.size.height)! / scrollView.contentSize.height;
            
            croprect.origin.x = scrollView.contentOffset.x * xOffset;
            croprect.origin.y = scrollView.contentOffset.y * yOffset;
            
            let normalizedWidth = (scrollView?.frame.width)! / (scrollView?.contentSize.width)!
            let normalizedHeight = (scrollView?.frame.height)! / (scrollView?.contentSize.height)!
            
            croprect.size.width = scrollView.imageToDisplay!.size.width * normalizedWidth
            croprect.size.height = scrollView.imageToDisplay!.size.height * normalizedHeight
            
            let toCropImage = scrollView.imageView.image?.fixImageOrientation()
            let cr: CGImage? = toCropImage?.cgImage?.cropping(to: croprect)
            let cropped = UIImage(cgImage: cr!)
            
            return cropped
            
        }
        private func isSquareImage() -> Bool {
            let image = scrollView.imageToDisplay
            if image?.size.width == image?.size.height { return true }
            else { return false }
        }
        
        
        // MARK: Public Functions
        
        func selectImageFromAssetAtIndex(index:NSInteger){
            
            ImageLoader.imageFrom(asset: photos[index], size: PHImageManagerMaximumSize) { (image) in
                DispatchQueue.main.async {
                    self.displayImageInScrollView(image: image)
                }
            }
        }
        
        func displayImageInScrollView(image:UIImage){
            self.scrollView.imageToDisplay = image
            if isSquareImage() { btnZoom.isHidden = true }
            else { btnZoom.isHidden = false }
        }
        
        func replicate(_ image:UIImage) -> UIImage? {
            
            guard let cgImage = image.cgImage?.copy() else {
                return nil
            }
            
            return UIImage(cgImage: cgImage,
                           scale: image.scale,
                           orientation: image.imageOrientation)
        }
        
        
      @objc func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) {
            
            let location = recognizer.location(in: view)
            
            if recognizer.state == .began {
                
                let cell: ILSImageSliderCollectionViewCell = recognizer.view as! ILSImageSliderCollectionViewCell
                indexPathOfImageViewToDrag = collectionView.indexPath(for: cell)
                imageViewToDrag = UIImageView(image: replicate(cell.imageView.image!))
                imageViewToDrag.frame = CGRect(x: location.x - cellWidth/2, y: location.y - cellWidth/2, width: cellWidth, height: cellWidth)
                view.addSubview(imageViewToDrag!)
                view.bringSubview(toFront: imageViewToDrag!)
            }
            else if recognizer.state == .ended {
                
                if scrollView.frame.contains(location) {
                    collectionView.selectItem(at: indexPathOfImageViewToDrag, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredVertically)
                    selectImageFromAssetAtIndex(index: indexPathOfImageViewToDrag.item)
                }
                
                imageViewToDrag.removeFromSuperview()
                imageViewToDrag = nil
                indexPathOfImageViewToDrag = nil
            }
            else{
                imageViewToDrag.center = location
            }
        }
    }
    
    
    
    
    
    extension ViewController:UICollectionViewDataSource{
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
            let cell:ILSImageSliderCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ILSImageSliderCollectionViewCell", for: indexPath) as! ILSImageSliderCollectionViewCell
            cell.populateDataWith(asset: photos[indexPath.item])
            cell.configureGestureWithTarget(target: self, action: #selector(handleLongPressGesture(recognizer:)))
            
            return cell
        }
    }
    
    
    extension ViewController:UICollectionViewDelegate{
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return photos.count
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let cell:ILSImageSliderCollectionViewCell = collectionView.cellForItem(at: indexPath) as! ILSImageSliderCollectionViewCell
            cell.isSelected = true
            selectImageFromAssetAtIndex(index: indexPath.item)
        }
    }
    
    
    extension ViewController:UICollectionViewDelegateFlowLayout{
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: cellWidth, height: cellWidth)
        }
}


