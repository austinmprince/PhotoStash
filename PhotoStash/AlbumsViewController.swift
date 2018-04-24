 //
//  AlbumsViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/16/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage


class AlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var notificationButton: UIBarButtonItem!
    @IBOutlet weak var albumsTableView: UITableView!
    var albums: [Album] = [] //an array to hold all the albums
    var reload = false
    var albumPass = ""
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    var currentUser = ""
    var spinner = UIActivityIndicatorView()

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: 0, width: 37, height: 37)
        spinner = UIActivityIndicatorView(frame: frame)
        spinner.center.x = view.center.x
        spinner.center.y = view.frame.size.height / 4.0
        spinner.hidesWhenStopped = true
        spinner.activityIndicatorViewStyle = .gray
        albumsTableView.addSubview(spinner)
        spinner.startAnimating()
        
        albumsTableView.delegate = self
        albumsTableView.dataSource = self
        
        ref = Database.database().reference()
        if Auth.auth().currentUser?.uid != nil {
            currentUser = (Auth.auth().currentUser?.uid)!
            print(currentUser)
        }
        
        loadAlbumData()
        
        
        //custom styles nav bar
        self.navigationController!.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 68.0)
        self.navigationController?.view.backgroundColor = .white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 25)!]
        
        //Creates album title
        let longTitleLabel = UILabel()
        longTitleLabel.text = "Albums"
        longTitleLabel.font = UIFont(name: "OpenSans-SemiBold", size: 25)
        longTitleLabel.sizeToFit()

        //Puts album title left
        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
        
        //hides navbar line
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //some logic to say that there are notifications to
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadFromBackground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //toolbabr
        self.navigationController?.isToolbarHidden = true
        self.navigationController?.toolbar.isHidden = true
    }
    
    @IBAction func createAlbum(_ sender: Any) {
        //pop modal
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = albumsTableView.dequeueReusableCell(withIdentifier:"albumCell", for: indexPath) as! AlbumTableViewCell
        let anAlbum = albums[indexPath.row]
        cell.setTitle(title: anAlbum.getTitle())
        cell.setAlbumImage(image: anAlbum.getAlbumImage())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let dateString = dateFormatter.string(from: anAlbum.getDateCreated())
        cell.setDateCreated(date: dateString)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let childVC = segue.destination as? AlbumInvitationTableViewController {
            childVC.parentVC = self
            
        }
        
        if let childVC = segue.destination as? CreateAlbumViewController {
            childVC.parentVC = self
        }
        if let childVC = segue.destination as? PhotosViewController {
            childVC.parentVC = self
            if let selectedCell = albumsTableView.indexPathForSelectedRow?.row {
                childVC.albumTitle = albums[selectedCell].getTitle()
            }
            
        }
        
    }
    func loadAlbumData() {
        ref = Database.database().reference()
        ref.child("Users").child(self.currentUser).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let invitesDict = value?["Invites"] {
//                print("im in here")
                let notificationButtonImage = UIImage(named: "notification-active-icon")?.withRenderingMode(.alwaysOriginal)
                self.notificationButton.image = notificationButtonImage
            }
            else {
                self.notificationButton.image = UIImage(named: "notification-icon")
            }
            if let albumList = value?["albums"] {
                let albList = albumList as? NSDictionary
                let albArray = albList?.allKeys
                if (albArray != nil) {
                    for element in albArray! {
                        
                        self.ref.child("Album").child(element as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                            let selectAlbum = snapshot.value as? NSDictionary
                            
                            if let imageURL = selectAlbum?["coverPhoto"] {
//                            if imageURL == nil {
                                let newAlbum = Album(title: element as! String, dateCreated: Date(), imgURL: imageURL as! String)
                                self.albums.append(newAlbum)
                               
                                
                            }
                                
                            else {
                                print("creating album without profile image")
                                let newAlbum = Album(title: element as! String, dateCreated: Date())
                                self.albums.append(newAlbum)
                               
                                
                            }
                            if let startDate = selectAlbum?["startDate"]{
                                if let members = selectAlbum?["Members"] as? NSDictionary {
                                    
                                    if let autoUp = members[self.currentUser] {
                                        if let endDate = selectAlbum?["endDate"] {
                                            if autoUp as? Int == 1 {
                                                DataHandler.fetchPhotosInRange(startString: startDate as! String, endString: endDate as! String, album: element as! String, user: self.currentUser)
                                            }
                                            
                                            
                                        }
                                    }
                                }
                            }
//                            print("album list size")
//                            print("\(self.albums.count)")
                            DispatchQueue.global(qos: .background).async {
                                DispatchQueue.main.async {
                                    print("IN ERE")
                                    self.albumsTableView.reloadData()
                                    self.spinner.stopAnimating()
                                }
                            }
                            
                            
                            
                        })
                    }
                }
            }
            else {
                self.albumsTableView.reloadData()
                self.spinner.stopAnimating()
                return
            }
        })
    }
    
    
    @objc func loadFromBackground() {
        self.albums.removeAll()
        loadAlbumData()
    }
    
    

}
