//
//  UsersAuthentication.swift
//  Cab2GoDriver
//
//  Created by Yevhenii on 21.04.2018.
//  Copyright © 2018 Yevhenii. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias LoginHandler = (_ message: String?) -> Void

struct LoginErrorCodeMessage {
    static let invalidEmailMessage = "Invalid Email Address. Please, Provide an Valid Email Address"
    static let wrongPasswordMessage = "Wrong Password. Please, Enter The Correct Password"
    static let problemConnectingMessage = "Cannot Connect to Database. Please, Try Again Later"
    static let userNotFoundMessage = "User Not Found. Please, Sign Up"
    static let emailAlreadyInUseMessage = "Email Is Already In Use. Please, Use Another Email"
    static let weakPasswordMessage = "Password Should Be At Least 6 Characters Long"
}

class UsersAuthenticationManager {
    
    //Creating a singleton for this class
    private static let instance = UsersAuthenticationManager()
    
    static var authManager: UsersAuthenticationManager {
        
        return instance
        
    }
    
    func signUp(email: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            
            if error != nil {
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
            } else {
                
                if user?.uid != nil {
                    
                    DatabaseManager.defaultManager.saveUser(withID: (user?.uid)!, email: email, password: password)
                    
                    self.login(email: email, password: password, loginHandler: loginHandler)
                }
                
            }
            
            
        })
        
    }
    
    func login(email: String, password: String, loginHandler: LoginHandler?) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { user, error in
            
            if error != nil {
                
                self.handleErrors(error: error! as NSError, loginHandler: loginHandler)
                
            } else {
                
                loginHandler?(nil)
                
            }
            
            //Handle user authorization
            
        })
        
    }
    
    func logOut() -> Bool {
        
        if Auth.auth().currentUser != nil {
            
            do {
                try Auth.auth().signOut()
                return true
            }
            catch {
                return false
            }
            
        }
        return true
    }
    
    private func handleErrors(error: NSError, loginHandler: LoginHandler?) {
        
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            
            switch errorCode {
                
            case .wrongPassword:
                loginHandler?(LoginErrorCodeMessage.wrongPasswordMessage)
            case .invalidEmail:
                loginHandler?(LoginErrorCodeMessage.invalidEmailMessage)
            case .userNotFound:
                loginHandler?(LoginErrorCodeMessage.userNotFoundMessage)
            case .emailAlreadyInUse:
                loginHandler?(LoginErrorCodeMessage.emailAlreadyInUseMessage)
            case .weakPassword:
                loginHandler?(LoginErrorCodeMessage.weakPasswordMessage)
            default:
                loginHandler?(LoginErrorCodeMessage.problemConnectingMessage)
                
            }
            
        }
        
    }
    
    
}

