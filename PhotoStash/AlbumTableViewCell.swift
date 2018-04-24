//
//  AlbumTableViewCell.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/16/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var albumDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        albumImageView.layer.cornerRadius = 2.0
        albumImageView.clipsToBounds = true
        
        let view = UIView(frame: albumImageView.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false;
        albumImageView.addSubview(view)
        albumImageView.bringSubview(toFront: view)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": view]))
        
        view.backgroundColor = UIColor.black
        view.alpha = 0.2
        
    }
    
    func setTitle(title: String){
        albumTitle.text = title
    }
    
    func setDateCreated(date: String){
        albumDate.text = date
    }
    
    func setAlbumImage(image: UIImage){
        albumImageView.image = image
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
