//
//  SetNicknameViewController.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 8. 29..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit
import FirebaseAuth

class SetNicknameViewController: UIViewController {
    var currentUser:User?
    var firebaseDBHelper:FirebaseDBHelper?
    
    @IBOutlet weak var txt_nickName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(String(describing: currentUser?.email)) -> USER EMAIL")
        print("\(String(describing: currentUser?.displayName)) -> USER NAME")
        
        self.firebaseDBHelper = FirebaseDBHelper()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OkBtnClicked(_ sender: Any) {
        var currentEmail : String!
        currentEmail = currentUser?.email
        self.firebaseDBHelper?.addNewUser(withId: currentEmail, _nickname: txt_nickName.text, _platform: "IDK") { (isAdded) in
            if isAdded {
                print("Registerd!")
            }else {
                print("Failed to registerd!")
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setnickname_to_home" {
            if let destinationVC = segue.destination as? HomeViewController {
                destinationVC.currentUser = self.currentUser
            }
        }
    }
    

}
