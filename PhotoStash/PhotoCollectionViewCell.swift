//
//  PhotoCollectionViewCell.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/23/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var photosViewController: PhotosViewController?
    
    override func awakeFromNib() {
//        imageView.isUserInteractionEnabled = true
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(animate))
//        imageView.addGestureRecognizer(tap)
        
    }
    
    @objc func animate(){
        
//        let zoomImageView = UIView()
//        zoomImageView.backgroundColor = .red
//        zoomImageView.frame = imageView.frame
//
//        imageView.addSubview(zoomImageView)
        
        print("From cell \(String(describing: imageView.superview))")
        
//        let largerImageView = UIImageView(image: imageView.image)
//        photosViewController?.animateImageView(photoImageView: largerImageView, thumbnameImageView: imageView)
    }
    
    func setImage(image: UIImage){
        imageView.image = image
    }
}
