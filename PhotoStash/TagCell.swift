//
//  TagCell.swift
//  UMates
//
//  Created by Austin Prince on 4/11/17.
//  Copyright © 2017 TheNerdHerd. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {

    @IBOutlet weak var tagName: UILabel!
    
    @IBOutlet weak var maxWidthConstraint: NSLayoutConstraint!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 15
        self.backgroundColor = .black
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor(red: 0.76, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
        self.tagName.textColor = .white
        self.maxWidthConstraint.constant = UIScreen.main.bounds.width - 7 * 2 - 7 * 2

    }

   
    

}
