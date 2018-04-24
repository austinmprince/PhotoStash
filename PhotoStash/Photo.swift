//
//  Photo.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/23/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import Foundation
import UIKit


class Photo {
    
    var imageURL: String?
    var nailURL: String?
    var fullImage: UIImage?
    var id:String?
    
    var nailImage: UIImage?
    
    init(full: String, nail: String, idString: String){
        self.imageURL = full
        self.nailURL = nail
        self.id = idString
        
        self.nailImage = DataHandler.getImage(path: nailURL!)
    }
    
    func getSnapshot() -> UIImage {
        return self.nailImage!
    }
    func getFull() -> UIImage {
        return DataHandler.getImage(path: self.imageURL!)
    }
}
