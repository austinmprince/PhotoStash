//
//  FakeData.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/13/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import Foundation
import UIKit

struct FakeData {
    
    static func getAlbums() -> [Album] {
        let date = Date()
        
        let albums = [
            Album(title: "Hawaii", dateCreated: date),
            Album(title: "Grand Canyon", dateCreated: date),
            Album(title: "Utah", dateCreated: date),
            Album(title: "The Zoo", dateCreated: date),
            Album(title: "Hanging out", dateCreated: date),
            Album(title: "Dinner Party", dateCreated: date)
        ]
        return albums
    }
    
//    static func getPhotos() -> [Photo] {
//        let photos = [
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "otherPhoto")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!),
//            Photo(image: UIImage(named: "albumimg")!)
//        ]
//        return photos
//    }
    
    static func getAlbumInvites() -> [AlbumInvite] {
        let invites = [
            AlbumInvite(userImage: UIImage(named: "profileImg")!, userName: "Lucy Diamonds", albumName: "SB2018"),
            AlbumInvite(userImage: UIImage(named: "profileImg")!, userName: "Lucy Diamonds", albumName: "SB2018"),
            AlbumInvite(userImage: UIImage(named: "profileImg")!, userName: "Lucy Diamonds", albumName: "SB2018"),
            AlbumInvite(userImage: UIImage(named: "profileImg")!, userName: "Lucy Diamonds", albumName: "SB2018"),
            AlbumInvite(userImage: UIImage(named: "profileImg")!, userName: "Lucy Diamonds", albumName: "SB2018")
        ]
        
        return invites
    }
    
}
