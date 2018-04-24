//
//  Album.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/13/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import Foundation
import UIKit

class Album {
    private var title: String?
    private var isAutoUpload: Bool?
    private var dateCreated: Date?
    private var albumImage: UIImage
    var coverURL : String?
    
    //    private var sharedWith: [Users}?
    
    init(title: String, dateCreated: Date){
        self.title = title
        isAutoUpload = false
        self.dateCreated = dateCreated
        self.albumImage = UIImage(named: "albumimg")!;
    }
    init(title: String, dateCreated: Date, autoUp: Bool){
        self.title = title
        self.isAutoUpload = false
        self.dateCreated = dateCreated
        self.albumImage = UIImage(named: "albumimg")!
        self.isAutoUpload = autoUp
        
        
        //        self.albumImage = UIImage(named: "albumimg")!;
    }
    
    init(title: String, dateCreated: Date, imgURL: String){
        self.title = title
        self.isAutoUpload = false
        self.dateCreated = dateCreated
        self.coverURL = imgURL
        self.albumImage = DataHandler.getImage(path: coverURL!)
        
        //        self.albumImage = UIImage(named: "albumimg")!;
    }
    
    public func setAlbumImage(albumImage: UIImage){
        self.albumImage = albumImage
    }
    
    public func getTitle() -> String {
        return title!
    }
    
    public func isAutoUploadActivated() -> Bool {
        return isAutoUpload!
    }
    
    public func setTitle(title: String){
        self.title = title
    }
    
    public func getDateCreated() -> Date{
        return self.dateCreated!
    }
    
    public func getAlbumImage() -> UIImage{
        return self.albumImage
    }
    
    public func toggleIsAutoUpload(title: String){
        if(self.isAutoUpload!){
            isAutoUpload = false
        }else{
            isAutoUpload = true
        }
    }
    
}
