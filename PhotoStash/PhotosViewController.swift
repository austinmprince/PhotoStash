//
//  PhotosViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/23/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import XLActionController
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ImagePicker


let imagePicker = ImagePickerController()

public var imageAssets: [UIImage] {
    return AssetManager.resolveAssets(imagePicker.stack.assets)
}

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, ImagePickerDelegate {
    
    var autoUploadSwitch = UISwitch()
    
    //spinner
    var spinner = UIActivityIndicatorView()
    
    //manage album
    let manageAlbumViewController = CreateAlbumViewController()
    

    //collection view
    @IBOutlet weak var collectionView: UICollectionView!
    let itemsPerRow = 3
    let sectionInsets = UIEdgeInsets(top: 1.0, left: 1.0, bottom: 1.0, right: 1.0)
    
    //data
    var albumTitle = ""
    var photos: [Photo] = []
    var currentUser = ""
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    var handleRef:UInt!
    var autoUp:Bool?
    var leaving = false
    
    var parentVC = AlbumsViewController()
   
    //animations
    let blackBackgroundView = UIView()
    let navBarCover = UIView()
    let toolBarCover = UIView()
    var photoImageView = UIImageView()
    var startFrame = CGRect()
    let zoomImageView = UIImageView()
    var originalImageView = UIImageView()
    var selectedCellIndex = IndexPath()
    
    //upload photos

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // user management
        ref = Database.database().reference()
        if Auth.auth().currentUser?.uid != nil {
            currentUser = (Auth.auth().currentUser?.uid)!
        }
        
        
        //data
        loadPhotoData()
        getAutoUpload()
        
        //navbar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.title = albumTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "more-icon"), style: .plain, target: self, action: #selector(morePressed))
        
        //toolbar
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.toolbar.barStyle = .default
        self.navigationController?.toolbar.backgroundColor = .white
        self.navigationController?.toolbar.isTranslucent = true
        var toolBarItems = [UIBarButtonItem]()
        autoUploadSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 51, height: 31))
        autoUploadSwitch.onTintColor = .gray
        let autoUploadLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 31))
        autoUploadLabel.text = "Auto upload"
        autoUploadLabel.font = UIFont(name: "OpenSans-SemiBold", size: 14)
        let labelBarItem = UIBarButtonItem(customView: autoUploadLabel)
        let barItem = UIBarButtonItem(customView: autoUploadSwitch)
        let flextItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBarItems.append(flextItem)
        toolBarItems.append(labelBarItem)
        toolBarItems.append(barItem)
        
        self.setToolbarItems(toolBarItems, animated: false)
        
        //spinner
        let frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        spinner = UIActivityIndicatorView(frame: frame)
        spinner.center.x = view.center.x
        spinner.center.y = (view.frame.size.height / 2.0) - 20
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .gray
        collectionView.addSubview(spinner)
        spinner.startAnimating()

    }
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeObserver(withHandle: handleRef)
        // updates the value of autoUpload if the user is not leaving the album
        if leaving == false {
            DataHandler.setAutoUpload(album: albumTitle, userId: currentUser, autoUp: autoUploadSwitch.isOn)
        }
    }
    
    //more button
    @objc func morePressed(){
        let actionController = YoutubeActionController()
        actionController.addAction(Action(ActionData(title: "Manage album", image: UIImage(named: "manage-people-icon")!), style: .default, handler: {alert in self.manageAlbum()}))
        actionController.addAction(Action(ActionData(title: "Upload photos", image: UIImage(named: "upload-photo-icon")!), style: .default, handler: {alert in self.uploadPhotos()}))
        actionController.addAction(Action(ActionData(title: "Leave album", image: UIImage(named: "leave-album-icon")!), style: .default, handler: {alert in self.leaveAlbum()}))
        self.present(actionController, animated: true, completion: nil)
    }
    
    func uploadPhotos(){
 
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)

    }
    
    func leaveAlbum(){
        leaving = true
        DispatchQueue.global(qos: .background).async {
            DataHandler.leaveAlbum(user: self.currentUser, album: self.albumTitle)
            DispatchQueue.main.async {
                self.parentVC.albums.removeAll()
                self.parentVC.loadAlbumData()
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        //communicate with previous view to remove album from list of albums
        //maybe remove it from their list of albums on the db and reload it
    }
    
    func manageAlbum(){
        self.performSegue(withIdentifier: "toManageAlbum", sender: self)
    }
    

    
    //collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"thumbnailCell", for: indexPath) as! PhotoCollectionViewCell
        let aPhoto = photos[indexPath.row]

        cell.setImage(image: aPhoto.getSnapshot())

        cell.photosViewController = self
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth = collectionView.bounds.width/3.0
        let yourHeight = yourWidth
        
        return CGSize(width: yourWidth-2, height: yourHeight-2)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //open up image
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        let photoImageView = UIImageView(image: cell.imageView.image)
        selectedCellIndex = indexPath
        self.originalImageView = cell.imageView
        cell.imageView.alpha = 0
        let offsetY = cell.frame.origin.y - self.collectionView.contentOffset.y
        let offsetCellFrame = CGRect(x: cell.frame.origin.x, y: offsetY, width: cell.frame.width, height: cell.frame.height)
        animateImageView(photoImageView: photoImageView, startFrame: offsetCellFrame, indexPath: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.5
    }
    
    
    //expanded photo view
    func animateImageView(photoImageView: UIImageView, startFrame: CGRect, indexPath: Int){
        //used for zoom out
        self.photoImageView = photoImageView
        self.startFrame = startFrame
        
        
        //creating expanded photo view
        blackBackgroundView.backgroundColor = .black
        blackBackgroundView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        blackBackgroundView.alpha = 0
        self.view.addSubview(blackBackgroundView)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.toolbar.frame.width)!, height: (self.navigationController?.toolbar.frame.height)!))
        toolBar.backgroundColor = .black
        toolBar.tintColor = .white
        toolBar.isTranslucent = false
        toolBar.barStyle = .black
        var toolBarItems = [UIBarButtonItem]()
        
        let deleteButton = UIButton()
        deleteButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
        deleteButton.frame = CGRect(x: 0, y: 0, width: 150, height: 32)
        deleteButton.backgroundColor = .clear
        deleteButton.tintColor = .white
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setImage(UIImage(named: "delete-photo-icon"), for: .normal)
        deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        deleteButton.addTarget(self, action: #selector(deletePhoto), for: .touchUpInside)
        
        let downloadButton = UIButton()
        downloadButton.titleLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
        downloadButton.frame = CGRect(x: 0, y: 0, width: 150, height: 32)
        downloadButton.backgroundColor = .clear
        downloadButton.tintColor = .white
        downloadButton.setTitle("Download", for: .normal)
        downloadButton.setImage(UIImage(named: "download-photo-icon"), for: .normal)
        downloadButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
        downloadButton.addTarget(self, action: #selector(downloadPhoto), for: .touchUpInside)
        
        let deletePhotoBarButton = UIBarButtonItem(customView: deleteButton)
        let downloadPhotoBarButton = UIBarButtonItem(customView: downloadButton)
        
        toolBarItems.append(deletePhotoBarButton)
        toolBarItems.append(downloadPhotoBarButton)
        toolBar.items = toolBarItems
        
        
        navBarCover.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: (self.navigationController?.navigationBar.frame.height)! + 70)
        navBarCover.backgroundColor = .black
        navBarCover.alpha = 0
        
        toolBarCover.frame = CGRect(x: (self.navigationController?.toolbar.frame.origin.x)!, y: (self.navigationController?.toolbar.frame.origin.y)!, width: (self.navigationController?.toolbar.frame.width)!, height: (self.navigationController?.toolbar.frame.height)! + 70)
        toolBarCover.backgroundColor = .black
        toolBarCover.alpha = 0
        toolBarCover.addSubview(toolBar)
        
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(self.navBarCover)
            keyWindow.addSubview(toolBarCover)
        }
        
        
        if photos[indexPath].imageURL != nil {
            photoImageView.image = photos[indexPath].getFull()
        }
        else {
            photoImageView.image = photos[indexPath].getSnapshot()
        }
        
        zoomImageView.image = photoImageView.image
        zoomImageView.contentMode = .scaleAspectFill
        zoomImageView.frame = startFrame
        zoomImageView.isUserInteractionEnabled = true
        view.addSubview(zoomImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomOut))
        blackBackgroundView.addGestureRecognizer(tap)
        
        //animate the view
        UIView.animate(withDuration: 0.25, animations: {
            let height = (self.view.frame.width / photoImageView.frame.width) * photoImageView.frame.height
            let y = (self.view.frame.height - (self.navigationController?.navigationBar.frame.height)! - 20) / 2 - height / 2
            self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
            self.blackBackgroundView.alpha = 1
            self.navBarCover.alpha = 1
            self.toolBarCover.alpha = 1
        }) {(didComplete) in
            let otherZoomView = UIImageView()
            otherZoomView.frame = self.zoomImageView.frame
            otherZoomView.image = self.zoomImageView.image
            self.blackBackgroundView.insertSubview(otherZoomView, at: 0)
            self.zoomImageView.alpha = 0
        }
    }
    
    @objc func zoomOut(){
        let view = self.blackBackgroundView.subviews[0]
        view.removeFromSuperview()
        self.zoomImageView.alpha = 1
        UIView.animate(withDuration: 0.25, animations: {
            self.blackBackgroundView.alpha = 0
            self.navBarCover.alpha = 0
            self.toolBarCover.alpha = 0
            self.zoomImageView.frame = self.startFrame
        }) { (didComplete) in
            self.originalImageView.alpha = 1
            self.zoomImageView.removeFromSuperview()
            self.blackBackgroundView.removeFromSuperview()
            self.navBarCover.removeFromSuperview()
            self.toolBarCover.removeFromSuperview()
        }
    }
    
    @objc func deletePhoto(){
        //pop up view to confirm deletion
       let alertController = UIAlertController(title: "", message: "This photo will be deleted from this album", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {alert in
            //zoomout of the image
            self.zoomOut()

            //remove that cell
            let photoURL = self.photos[self.selectedCellIndex.row].id!
            self.photos.remove(at: self.selectedCellIndex.row)
            self.collectionView.deleteItems(at: [self.selectedCellIndex])
            DataHandler.removePhotoWID(id: photoURL, album: self.albumTitle)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    @objc func downloadPhoto(){
        
        let alertController = UIAlertController(title: "", message: "This photo will be saved into your camera roll", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Save image", style: .default, handler: {alert in
           //write image to phone
            UIImageWriteToSavedPhotosAlbum(self.originalImageView.image!, self, nil, nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        let images = imageAssets
        DataHandler.uploadImageArray(array: images, album: albumTitle)
        imagePicker.dismiss(animated: true, completion: nil)

    }
    
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func getAutoUpload()  {
        ref.child("Album").child(albumTitle).child("Members").child(currentUser).observeSingleEvent(of: .value, with: {(snapshot) in
            if let value = snapshot.value as? Int{
                if value == 0 {
                    self.autoUploadSwitch.isOn = false
                }
                else {
                    self.autoUploadSwitch.isOn = true
                }
            }
        })
       
    }
    func loadPhotoData(){
        print("reloading photo data")
        handleRef = ref.child("AlbumPhotos").child(albumTitle).observe(.value, with: {(snapshot) in
            let results = snapshot.value as? NSDictionary
            let listElement = results?.allValues
//            print("list element")
//            print(listElement)
            DispatchQueue.global(qos: .background).async {
            if let urlList = listElement {
                
                for element in urlList {
//                    print("single element")
//                    print(element)
                    var dict = element as! NSDictionary
                    var key = results?.allKeys(for: element)
                    
                    let keyString = key![0] as? String
                    guard let nailURL = dict["nail"] as? String else { continue }
                    guard let fullURL = dict["full"] as? String else { continue }

                    let photo = Photo(full: fullURL, nail: nailURL, idString: keyString!)
                    if !self.photos.contains(where: {$0.id == keyString}) {
                        self.photos.append(photo)
                    }
                    
                    print("\(self.photos.count)")
//                    if self.photos.count <= 16 {
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.spinner.stopAnimating()
//                        }
                    }
                    }
                    
                    
                }
                
            
            
            else {
                self.spinner.stopAnimating()
                return
            }
            }
            
        })
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.destination is CreateAlbumViewController {
            let vc = segue.destination as? CreateAlbumViewController
            vc?.navBarTitleText = "Manage album"
            vc?.updating = true
            vc?.albumTitle = albumTitle
            vc?.autoUp = autoUploadSwitch.isOn
            vc?.photoVCSwitch = self.autoUploadSwitch
        }
        // Pass the selected object to the new view controller.
    }
 

}
