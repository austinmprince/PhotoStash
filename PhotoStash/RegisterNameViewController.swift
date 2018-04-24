//
//  RegisterNameViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/14/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import ImagePicker



class RegisterNameViewController: UIViewController, UITextFieldDelegate, ImagePickerDelegate {

    let profPicker = ImagePickerController()
    public var imageAssets: [UIImage] {
        return AssetManager.resolveAssets(profPicker.stack.assets)
    }
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    var nextBarItem = UIBarButtonItem()
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.isTranslucent = false
        toolbar.backgroundColor = .black
        
        //bar items
        nextBarItem = UIBarButtonItem(image: UIImage(named: "next-bar-item-icon"), style: .plain, target: self, action: #selector(toNextPage))
        nextBarItem.tintColor = UIColor.white
        nextBarItem.isEnabled = false
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        profPicker.imageLimit = 1
        toolbar.setItems([flexSpace, nextBarItem], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        firstNameTextField.inputAccessoryView = toolbar
        lastNameTextField.inputAccessoryView = toolbar
        
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        firstNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height / 2
//        profilePictureImageView.image = UIImage(named: "profileImg")
    }
    
    @objc func dismissKeyboard(){
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(firstNameTextField.hasText && lastNameTextField.hasText){
            nextBarItem.isEnabled = true
        }
    }
    
    @objc func toNextPage(){
        if(firstNameTextField.hasText && lastNameTextField.hasText){
            self.performSegue(withIdentifier: "toRegister2", sender: self)
        }
    }
    
    @IBAction func setProfilePicturePressed(_ sender: Any) {
        profPicker.delegate = self
        present(profPicker, animated: true, completion: nil)
    }
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    
    @IBAction func cancelModalPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        let images = imageAssets
        if images.count == 1 {
            profilePictureImageView.image = images[0]
        }
        profPicker.dismiss(animated: true, completion: nil)
        
    }
    
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        profPicker.dismiss(animated: true, completion: nil)
    }
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegister2" {
            if let childVC = segue.destination as? RegisterEmailViewController {

            if let profPic = profilePictureImageView.image {
                let user = User(first: firstNameTextField.text!, last: lastNameTextField.text!, image: profilePictureImageView.image!)
                childVC.user = user
            }
            else {
                let user = User(first: firstNameTextField.text!, last: lastNameTextField.text!, image: UIImage(named: "profileImg")!)
                childVC.user = user
            }
            
////            if let childVC = segue.destination as? RegisterEmailViewController {
//                childVC.user = user
//            }
        }
    }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
