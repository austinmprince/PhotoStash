//
//  RegisterEmailViewController.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/15/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit

class RegisterEmailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    var nextBarItem = UIBarButtonItem()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        //navbar
        self.navigationController?.navigationBar.tintColor = .white
        
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
        
        toolbar.setItems([flexSpace, nextBarItem], animated: false)
        toolbar.isUserInteractionEnabled = true
        toolbar.sizeToFit()
        
        emailTextField.inputAccessoryView = toolbar
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if(emailTextField.hasText){
            nextBarItem.isEnabled = true
        }
    }
    
    @objc func toNextPage(){
        if(isValidEmail(testStr: emailTextField.text!)){
            
            self.performSegue(withIdentifier: "toRegisterFinal", sender: self)
        }
        else {
            let alertController = UIAlertController(title: "Error", message: "Must Enter A Valid Email Address", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegisterFinal" {
            self.user.setEmail(emailString: emailTextField.text!)
            if let childVC = segue.destination as? RegisterPasswordViewController {
                childVC.userRegister = self.user
            }
        }
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
