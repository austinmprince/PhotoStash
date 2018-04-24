//
//  AlbumCollectionViewController.swift
//  PhotoStash
//
//  Created by Ifeoma Ufondu on 2/13/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class AlbumCollectionViewController: UICollectionViewController {
    
    var albums: [Album] = [] //an array to hold all the albums
    
    override func viewDidLoad() {
        super.viewDidLoad()
        albums = FakeData.getAlbums()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"albumCell", for: indexPath) as! AlbumCollectionViewCell
        
        let anAlbum = albums[indexPath.row]
        cell.setTitle(title: anAlbum.getTitle())
        
        return cell
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */

}
