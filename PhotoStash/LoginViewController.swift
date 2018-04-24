//
//  LoginViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 2/24/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let username = username.text else { return }
        guard let password = password.text else { return }
        Auth.auth().signIn(withEmail: username, password: password, completion: {(user, error) in
            if error != nil {
                var message: String = ""
                print("I had an error")
                Auth.auth().fetchProviders(forEmail: username, completion: { (emails, error) in
                    if error != nil {
                        message = "Invalid email"
                        return
                    }
                    else if emails?.count == 0 {
                        message = "Invalid email"
                    }
                    else {
                        message = "Invalid password"
                    }
                })
                if message.count == 0 {
                    message = "Invalid login credentials"
                }
                
                let alertController = UIAlertController(title: "Login Failed!", message: message, preferredStyle: .alert)
                
                
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) -> Void in
                    //do nothing aka close alert
                })
                
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                //self.presentedViewController(alertController, animated:)
                //self.present(alertController, animated: true, completion: nil)
                return
            }
            
            
            self.performSegue(withIdentifier: "login2", sender: sender)
            
        })
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.backgroundColor = .black;
        loginButton.tintColor = .white;
        loginButton.layer.cornerRadius = 3;
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        self.username.resignFirstResponder()
        self.password.resignFirstResponder()
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
