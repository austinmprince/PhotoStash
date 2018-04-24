//
//  AlbumTableViewController.swift
//  PhotoStash
//
//  Created by Ifeoma Ufondu on 2/13/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AlbumTableViewController: UITableViewController {
    var ref: DatabaseReference?
    var myList:[String] = []
    var handle:DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        //Sync with Firebase Database
        handle = ref?.child("Album").child("Album_1").observe(.childAdded, with: {(snapshot) in
            if let item = snapshot.value as? String {
                self.myList.append(item)
                self.tableView.reloadData()
                self.ref?.keepSynced(true)
            }
        })
    }

    @IBAction func addItemBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title:"Enter Content", message:"Save to Firebase", preferredStyle:.alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Album Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Album Owner"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title:"Save", style: .default, handler: {(action) in
            let textField1 = alert.textFields?.first
            let textField2 = alert.textFields?.last  //Here i'm trying to get all the second value in the textfield
            if textField1?.text != "" {
                let code = self.ref?.child("Album").childByAutoId()
                code?.child("Title").setValue(textField1?.text)
                code?.child("Owner").setValue(textField2?.text)
                
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = myList[indexPath.row]
        // Configure the cell...

        return cell
    }


}
