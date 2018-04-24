//
//  RegisterPasswordViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/15/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    var signupBarItem = UIBarButtonItem()
    var userRegister = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(userRegister.getFirstName())
        print(userRegister.getLastName())
        print(userRegister.getEmail())

        //navbar
        self.navigationController?.navigationBar.tintColor = .white
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .black
        toolbar.isTranslucent = false
        toolbar.backgroundColor = .black
        
        let signupButton = UIButton(frame: CGRect(x: 0, y: 0, width: 86, height: 33))
        signupButton.layer.cornerRadius = 3
        signupButton.backgroundColor = .white
        signupButton.setTitleColor(.black, for: .normal)
        signupButton.titleLabel?.text = "Sign up"
        signupButton.titleLabel?.font = UIFont(name: "OpensSans-SemiBold", size: 14)
        signupButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        
        //bar items
//        signupBarItem = UIBarButtonItem(customView: signupButton)
        signupBarItem = UIBarButtonItem(title: "Sign up", style: .plain, target: self, action: #selector(signUp))
        signupBarItem.tintColor = .white
        signupBarItem.isEnabled = false
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexSpace, signupBarItem], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        toolbar.sizeToFit()
        
        passwordTextField.inputAccessoryView = toolbar
        confirmPasswordTextField.inputAccessoryView = toolbar
        
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(passwordTextField.hasText && confirmPasswordTextField.hasText){
            signupBarItem.isEnabled = true
        }
    }
    
    @objc func signUp(){
        print("In here")
        if(passwordTextField.hasText && confirmPasswordTextField.hasText){
            if(passwordTextField.text == confirmPasswordTextField.text){
                let password = passwordTextField.text!
                
                let confirmPassword = confirmPasswordTextField.text!
                Auth.auth().createUser(withEmail: userRegister.getEmail(), password: password, completion: {(user, error) in
                    if error != nil {
                        print("There was an error on registration")
                    }
                    else {
                        self.userRegister.setUid(uidString: (user?.uid)!)
                        DataHandler.registerUser(user: self.userRegister)
                    }
                })
                self.dismiss(animated: true, completion: nil)
            }
            else {
                print("alerts arent working")
                let alertController = UIAlertController(title: "Error", message: "Passwords must match", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        else {
            print("alerts arent working")
            let alertController = UIAlertController(title: "Error", message: "Must create a password", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
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
