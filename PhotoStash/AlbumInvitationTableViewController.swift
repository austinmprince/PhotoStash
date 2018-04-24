//
//  AlbumInvitationTableViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/11/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class AlbumInvitationTableViewController: UITableViewController {
    
    //data
    var parentVC = AlbumsViewController()
    var invites: [AlbumInvite] = []
    var albums:[String:String] = [:]
    var accepted:[String:Bool] = [:]
    var currentUser = ""
    var ref: DatabaseReference!
    var handle:DatabaseHandle?

    @IBOutlet weak var navbar: UINavigationBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        if Auth.auth().currentUser?.uid != nil {
            currentUser = (Auth.auth().currentUser?.uid)!
            
        }
        loadInvites()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //custom styles nav bar
        navbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 68.0)
        navbar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 19)!]
        
        //hides navbar line
        navbar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navbar.shadowImage = UIImage()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return invites.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invitationCell", for: indexPath) as! InviteTableViewCell
        let invite = invites[indexPath.row]
        cell.setUserImage(image: invite.getUserImage())
        cell.setUserName(userName: invite.getUserName())
        cell.setAlbumName(albumName: invite.getAlbumName())
        cell.setInviteText()
        if let acceptedInvite = cell.accepted {
            accepted[invite.getAlbumName()] = acceptedInvite
        }
        return cell
    }
 
    @IBAction func closeAlbumInvitations(_ sender: UIBarButtonItem) {
        for cell in tableView.visibleCells as! [InviteTableViewCell] {
            if let confirmCell = cell.accepted {
                accepted[cell.albumName] = confirmCell
            }
        }
        if !accepted.values.isEmpty {
            DataHandler.acceptInvite(user: currentUser, albums: accepted)
        }
        parentVC.albums.removeAll()
        parentVC.loadAlbumData()
        dismiss(animated: true, completion: nil)
   
    }
    func loadInvites () {
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.async {
                self.ref.child("Users").child(self.currentUser).observeSingleEvent(of: .value, with: {(snapshot) in
                    let dict = snapshot.value as? NSDictionary
                    if let inviteShot = dict!["Invites"]  {
                        let inviteDict = inviteShot as! NSDictionary
                        for (key, value) in inviteDict {
                            self.ref.child("Users").child(value as! String).observeSingleEvent(of: .value, with: {(snapshotTwo) in
                                let dictTwo = snapshotTwo.value as? NSDictionary
                                
                                let username = dictTwo!["username"] as! String
                                if let profURL = dictTwo!["profPic"] {
                                    let profImg = DataHandler.getImage(path: profURL as! String)
                                    let albumInvite = AlbumInvite(userImage: profImg, userName: username, albumName: key as! String)
                                    print("in here")
                                    self.invites.append(albumInvite)
                                }
                                else {
                                    let profImg = UIImage(named: "profileImg")
                                    let albumInvite = AlbumInvite(userImage: profImg!, userName: username, albumName: key as! String)
                                    self.invites.append(albumInvite)
                                }
                                self.tableView.reloadData()
                            })
                        }
                    }
                    
                })
                
                
            }
        }
    }
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
