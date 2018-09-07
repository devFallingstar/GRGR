//
//  LoginViewController.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 8. 29..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit
import FirebaseUI
import FirebaseStorage
import FirebaseFirestore

class LoginViewController: UIViewController, FUIAuthDelegate {
    var auth:Auth?
    var authUI:FUIAuth?
    var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    var firebaseDBHelper:FirebaseDBHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initAuthInformation()
        initDBInformation()
        
        self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
            
            if user != nil {
                self.performSegue(withIdentifier: "login_to_home", sender: nil)
            }else {
                self.loginAction(sender: self)
            }
        }
    }
    
    func initAuthInformation() {
        self.auth = Auth.auth()
        
        // Test code
//        do {
//            try self.auth?.signOut()
//            print("SignOUt!")
//        } catch  {
//            print("Error!!! : \(error)")
//        }
        // Test code
        
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self
        self.authUI?.providers = [
            FUIGoogleAuth(),
            FUIFacebookAuth(),
        ]
    }
    
    func initDBInformation() {
        self.firebaseDBHelper = FirebaseDBHelper()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginAction(sender: AnyObject) {
        //        let authViewController = authUI?.authViewController();
        let authViewController = CustomFBAuthViewController(authUI: authUI!)
        let navController = UINavigationController(rootViewController: authViewController)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard let authError = error else { return }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
            
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        let userData = authDataResult?.user
        let id = userData?.email
        self.firebaseDBHelper?.getUserInfo(withId: id) {
            (isExist) in
            if isExist {
                self.performSegue(withIdentifier: "login_to_home", sender: nil)
            }else {
                self.performSegue(withIdentifier: "login_to_setnickname", sender: nil)
            }
        }
        
//        print("Has user data with id \(String(describing: id)) : \(String(describing: self.firebaseDBHelper?.getUserInfo(withId: id)))")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login_to_setnickname" {
            if let destinationVC = segue.destination as? SetNicknameViewController {
                destinationVC.currentUser = self.auth?.currentUser
            }
        }
        if segue.identifier == "login_to_home" {
            if let destinationVC = segue.destination as? HomeViewController {
                destinationVC.currentUser = self.auth?.currentUser
            }
        }
    }
}

