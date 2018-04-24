//
//  SignUpViewController.swift
//  PhotoStash
//
//  Created by Ifeoma Ufondu on 2/9/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {
    var ref: DatabaseReference?
    var handle:DatabaseHandle?

 
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    @IBAction func signUpPressed(_ sender: Any) {
        guard let username = username.text else {return}
        guard let email = email.text else {return}
        guard let password = password.text else {return}
        guard let confirmPassword = confirmPassword.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if(error != nil) {
                var message: String = ""
                if password.characters.count < 6 && self.isValidEmail(testStr: email) == false {
                    message = "Invalid emai. \nPassword must be longer than 6 characters."
                }
                else if password.characters.count < 6 {
                    message = "longer password"
                }
                else if self.isValidEmail(testStr: email) == false {
                    message = "bad email"
                }
                else if password != confirmPassword {
                    message = "passwords must match"
                }
                let alertController = UIAlertController(title: "Okay", message: message, preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: {(action) -> Void in
                    //do notiing
                })
                
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            guard let uid = user?.uid else {return}
            //let values = ["name": username, "email": email] as [String : Any]
            //self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String: AnyObject])
            self.registerUserIntoDatabaseWithUID(uid: uid, email: email, username: username)
            
            
            if username != "" {
                let code = self.ref?.child("Users").child((uid)) //create a new user
                code?.child("username").setValue(username)
                code?.child("albums").setValue(nil)
            }
            //let VC = storyboard?.instantiateViewController(withIdentifier: "AlbumViewVC") as! AlbumCollectionViewController
            
            Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
                if error == nil {
                    print("damn")
                    self.performSegue(withIdentifier: "signup2", sender: sender)
                }
                else {
                    var message = "Ohshit"
                    let alertController = UIAlertController(title: "Oh shit", message: message, preferredStyle: .alert)
                    
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: {(action) -> Void in
                        //do notiing
                    })
                    
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
            } )
            
            
        })
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, email: String, username :String) {
        let ref = Database.database().reference()
        let usersReference = ref.child("Users").child(uid)
        usersReference.child("username").setValue(username)
        usersReference.child("email").setValue(email)
     
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
