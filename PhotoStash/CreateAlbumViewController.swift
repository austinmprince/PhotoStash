//
//  CreateAlbumViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/19/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchResultsUpdating, UISearchBarDelegate, UIScrollViewDelegate  {
    
    @IBOutlet weak var createButton: UIBarButtonItem!
    @IBOutlet weak var albumNameTextField: UITextField!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    var sizingCell: TagCell?
    @IBOutlet weak var timeTableView: UITableView!
    @IBOutlet weak var autoUpload: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var searchContainer: UIView!
    var ref: DatabaseReference!
    var handle:DatabaseHandle?
    var autoUp:Bool = false
    var currentUser = ""
    var updating:Bool = false
    var albumTitle = ""
    
    
    //passed in variables
    var navBarTitleText = ""
    
    //search
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    var filteredUsers = [String]()
    var didTapSearchContainer = false
    
    //data
    var alreadyIn = [String]()
    var selectedUsers = [String]()
    var selectedKeys = [String]()
    var allUsers:[String:String] = [:]
    var nameToKey:[String:String] = [:]
    var parentVC = AlbumsViewController()
    
    var photoVCSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        if Auth.auth().currentUser?.uid != nil {
            currentUser = (Auth.auth().currentUser?.uid)!
            
        }
        if updating == true {
            getAlbumData()
            autoUpload.isOn = autoUp
        }
        else {
            autoUpload.isOn = false
        }
        
        //scrollView
        scrollView.delegate = self
        
        //custom styles nav bar
        navbar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 68.0)
        navbar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "OpenSans-SemiBold", size: 19)!]
        navbar.topItem?.title = navBarTitleText
        
        //hides navbar line
        navbar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navbar.shadowImage = UIImage()

        //people collection view
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.collection.register(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.collection.backgroundColor = UIColor.clear
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)
        
        //tableview
        timeTableView.delegate = self
        timeTableView.dataSource = self
//        autoUpload.isOn = false
        showTimeTableView(shouldShow: !(autoUpload.isOn))
        
        //keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        //gestures
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(dismissKeyboardTap)
        
        let activateSearchTap = UITapGestureRecognizer(target: self, action: #selector(activateSearch))
        self.searchContainer.addGestureRecognizer(activateSearchTap)
        
        //search
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        self.definesPresentationContext = false
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchController.searchBar.backgroundImage = UIImage()
        
        getUsers { (success) -> Void in
            if success {
                // do second task if success
                self.resultsController.tableView.reloadData()
                
            }
        }
   
    }
    
    func showTimeTableView(shouldShow: Bool){
        timeTableView.isHidden = shouldShow
    }

    @IBAction func cancelCreateAlbum(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAlbum(_ sender: Any) {
        let date = Date()
        let startRow = IndexPath(row: 0, section: 0)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyy    h:mma"
        let endRow = IndexPath(row: 1, section: 0)
        let startCell = timeTableView.cellForRow(at: startRow) as? SelectTimeTableViewCell
        let startTime = startCell?.timeTextField.text!
        let startDate = formatter.date(from: startTime!)
        let endCell = timeTableView.cellForRow(at: endRow) as? SelectTimeTableViewCell
        let endTime = endCell?.timeTextField.text!
        let endDate = formatter.date(from: endTime!)
        let albumTitle = albumNameTextField.text!
        
        let _ = Album(title: albumTitle, dateCreated: date)
        //push album into db
        self.selectedKeys.removeAll()
        print(selectedUsers)
        print(alreadyIn)
        for value in selectedUsers {
            if !(self.alreadyIn.contains(value)) {
                print(value)
                let key = self.nameToKey[value]
                if !(key! == self.currentUser) {
                    selectedKeys.append(key!)
                }
            }
            
        }
        
        if endDate! < startDate! {
            let alertController = UIAlertController(title: "Error", message: "End Date Must be After Start Date", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
            
            
        }
        if albumTitle == ""{
            
            let alertController = UIAlertController(title: "Error", message: "Must have album title", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        print("doing final things that I maybe dont' want to do but am doing anyways")
        DataHandler.sendInvites(people: selectedKeys, album: albumTitle, inviteUser: currentUser)
        DataHandler.createAlbum(creator: currentUser, albumTitle: albumTitle, autoUpload: autoUp, startDate: startDate, endDate: endDate)
        if updating {
            photoVCSwitch.isOn = autoUpload.isOn
        }
        if updating && autoUpload.isOn {
            DataHandler.updateDates(album: albumTitle, startDate: startDate, endDate: endDate, user: self.currentUser, autoUpload: autoUpload.isOn)
        }
        if !updating {
            parentVC.albums.removeAll()
            parentVC.loadAlbumData()
        }
        dismiss(animated: true, completion: nil)
    }
    
    //collection view functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        self.configureCell(cell: cell, forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        self.configureCell(cell: self.sizingCell!, forIndexPath: indexPath)
        return self.sizingCell!.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell  = collectionView.cellForItem(at: indexPath) as! TagCell
        let userName = cell.tagName.text
        let indexOfUser = selectedUsers.index(of: userName!)
        selectedUsers.remove(at: indexOfUser!)
        collectionView.reloadData()
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: IndexPath){
        let tag = selectedUsers[indexPath.row]
        cell.tagName.text = tag
    }
    
    //table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == timeTableView {
            return 2
        }
        
        if searchController.isActive {
            return filteredUsers.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == timeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath) as! SelectTimeTableViewCell
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, yyy    h:mma"
            let result = formatter.string(from: date)
            
            if indexPath.row == 0 {
                cell.setAssociatedTimeLabel(associatedTimeText: "Start")
                cell.setTimeTextField(timeText: result)
                
                return cell
            }
            
            cell.setAssociatedTimeLabel(associatedTimeText: "End")
            cell.setTimeTextField(timeText: result)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if searchController.isActive {
            cell.textLabel?.font = UIFont(name: "OpenSans", size: 14.0)
            cell.textLabel?.text = filteredUsers[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == timeTableView {
            let cell =  tableView.cellForRow(at: indexPath) as! SelectTimeTableViewCell
            cell.didSelect()
            keyboardWillShow(textField: cell.timeTextField)
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            let cellTitle = cell?.textLabel?.text
            selectedUsers.append(cellTitle!)
            collection.reloadData()
            filteredUsers.removeAll()
            searchController.searchBar.text = ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    //Switch
    @IBAction func toggleAutoUpload(_ sender: UISwitch) {
        autoUp = !autoUp
        showTimeTableView(shouldShow: !(sender.isOn))
    }
    
    //keyboard
    func keyboardWillShow(textField: UITextField){
        var point = CGPoint()
        point.x = 0
        if textField ==  getSearchBarTextField(){
            point.y = peopleLabel.frame.origin.y

        } else {
            point.y = timeTableView.frame.height
        }

        scrollView.setContentOffset(point, animated: true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let point = CGPoint(x: 0, y: 0)
            scrollView.setContentOffset(point, animated: true)
        }
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
        
        print(didTapSearchContainer)
        if didTapSearchContainer {
            searchController.searchBar.isHidden = true
            searchController.isActive = false
//            searchContainer.subviews.forEach({ $0.removeFromSuperview() })
            searchContainer.subviews[1].removeFromSuperview()
            print(searchContainer.subviews)
            didTapSearchContainer = false
            searchController.view.endEditing(true)
        }
        
    }
    
    //search
    func updateSearchResults(for searchController: UISearchController){
        filteredUsers.removeAll(keepingCapacity: false)
        let searchPredict = NSPredicate(format: "SELF CONTAINS[c] %@ ", searchController.searchBar.text!)
        let values = Array(self.allUsers.values)
        let array = (values as NSArray).filtered(using: searchPredict)
        self.filteredUsers = array as! [String]
        resultsController.tableView.reloadData()
    }
    
    func getSearchBarTextField() -> UITextField{
        let returnTextField = UITextField()
        for subView in searchController.searchBar.subviews
        {
            for subsubView in subView.subviews
            {
                if let textField = subsubView as? UITextField
                {
                    return textField
                }
            }
        }
        return returnTextField
    }
    
    @objc func activateSearch(){
        keyboardWillShow(textField: getSearchBarTextField())
        didTapSearchContainer = true
    }
    
    
    
    //scrollView
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if didTapSearchContainer {
            self.searchContainer.addSubview(searchController.searchBar)
            searchController.searchBar.isHidden = false
            searchController.searchBar.becomeFirstResponder()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func getUsers(success: @escaping (Bool) -> Void) {
        ref.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            let users = snapshot.value as? NSDictionary
            // pulls out the username/email from the values and populates the userList array
            // with these values
            // could have problems if one of the two (username/email) is not required
            // might want to check on that
            for (key, value) in users! {
                
                let values = value as! NSDictionary
                print(values)
                
                if let username = values["username"] {
                    self.allUsers[key as! String] = String(describing: username)
                    self.nameToKey[username as! String] = String(describing: key)
                }
                else  {
                    let username = values["email"]
                    self.allUsers[key as! String] = String(describing: username)
                    self.nameToKey[username as! String] = String(describing: key)
                }
                
            }
            success(true)
        })
        
    }
    
    func getSelectedUsers() {
            for item in self.selectedKeys {
    
                    self.ref.child("Users").child(item).observeSingleEvent(of: .value, with: {(snapshot) in
                        let values = snapshot.value as? NSDictionary
                        let username = values?["username"]
                        self.selectedUsers.append(username as! String)
                        self.alreadyIn.append(username as! String)
                        print(self.selectedUsers)
                        self.collection.reloadData()
                    })
                
                
                
                
        }
    }
    
    func getAlbumData() {
        albumNameTextField.text! = albumTitle
        ref.child("Album").child(albumTitle).observeSingleEvent(of: .value, with: {(snapshot) in
            let values = snapshot.value as? NSDictionary
            let members = values?["Members"] as? NSDictionary
            let keys = members?.allKeys as? [String]
            self.selectedKeys = keys!
            self.getSelectedUsers()
            
       
            if let endDate = values?["endDate"] {
                if let startDate = values?["startDate"] {
                    print(startDate)
                    let formatterIn = DateFormatter()
                    let formatterOut = DateFormatter()
                    formatterOut.dateFormat = "MMMM dd, yyy    h:mma"
                    formatterIn.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    let startDateTest = formatterIn.date(from: startDate as! String)
                    let endDateTest = formatterIn.date(from: endDate as! String)
                    let date = Date()
                    if endDateTest! > date {
                        let endString = formatterOut.string(from: endDateTest!)
                        let startString = formatterOut.string(from: startDateTest!)
                        self.showTimeTableView(shouldShow: false)
                        let endRow = IndexPath(row: 1, section: 0)
                        let startRow = IndexPath(row: 0, section: 0)
                        let endCell = self.timeTableView.cellForRow(at: endRow) as? SelectTimeTableViewCell
                        endCell?.timeTextField.text = endString
                        print(startString)
                        
                        let startCell = self.timeTableView.cellForRow(at: startRow) as? SelectTimeTableViewCell
                        startCell?.timeTextField.text = startString
                    }
                }
                
            }
            
            
        })
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.destination is CreateAlbumViewController{
            let vc = segue.destination as? CreateAlbumViewController
            vc?.navBarTitleText = "Manage album"
        }
        // Pass the selected object to the new view controller.
    }
 

}
