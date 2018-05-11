//
//  ViewController.swift
//  Cab2GoDriver
//
//  Created by Yevhenii on 18.04.2018.
//  Copyright © 2018 Yevhenii. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    private let mapSegueIdentifier = "ShowMapVC"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK:- Other Methods
    
    private func alertUser(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alerAction_OK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alerAction_OK)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            UsersAuthenticationManager.authManager.login(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: { message in
                
                if message != nil {
                    
                    self.alertUser(title: "Authentication Error", message: message!)
                    
                } else {
                    CabUnitManager.defaultManager.driver = self.emailTextField.text!
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.mapSegueIdentifier, sender: nil)
                    
                }
                
            })
            
        } else {
            
            alertUser(title: "Email And Password Are Required", message: "Please, enter your Email and Password in the text fields")
            
        }
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            UsersAuthenticationManager.authManager.signUp(email: emailTextField.text!, password: passwordTextField.text!, loginHandler: {message in
                
                if message != nil {
                    //Message is not nil, so there is an error. Unable to register.
                    self.alertUser(title: "Problem With Creating A New User", message: message!)
                    
                } else {
                    
                    CabUnitManager.defaultManager.driver = self.emailTextField.text!
                    
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.mapSegueIdentifier, sender: nil)
                    
                }
                
            })
            
        } else {
            
            alertUser(title: "Email And Password Are Required", message: "Please, enter your Email and Password in the text fields")
            
        }
    }
    
}

