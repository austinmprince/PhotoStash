//
//  AlbumInvite.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/11/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import Foundation
import UIKit

class AlbumInvite {
    private var userImage: UIImage
    private var userName: String?
    private var albumName: String?
    
    init(userImage: UIImage, userName: String, albumName: String) {
        self.userName = userName
        self.albumName = albumName
        self.userImage = userImage
    }
    
    func getAlbumName() -> String {
        return self.albumName!
    }
    
    func getUserImage() -> UIImage {
        return self.userImage
    }
    
    func getUserName() -> String {
        return self.userName!
    }
}
