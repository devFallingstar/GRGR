//
//  PostWritingViewController.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 9. 7..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AZDialogView
import FirebaseAuth

class PostWritingViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, NVActivityIndicatorViewable {
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_article: UITextView!
    
    var selectedPictureID:String!
    var currentEmail:String!
    var firebaseDBHelper:FirebaseDBHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
        initDBInformation()
    }
    
    func initUI() {
        txt_title.placeholder = "제목"
        txt_title.delegate = self
        txt_article.delegate = self
    }
    
    func initDBInformation() {
        self.firebaseDBHelper = FirebaseDBHelper()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func onBackBtnClicked(_ sender: Any) {
        print("Back btn clicked")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneBtnClicked(_ sender: Any) {
        let str_title:String! = txt_title.text!
        let str_content:String! = txt_article.text!
        var DocumentID:String!
        
        if str_content != "" && str_title != "" {
            self.startAnimating(message: "글 작성 중", type: NVActivityIndicatorType.ballPulse)
            
            DocumentID = self.firebaseDBHelper?.addNewArticleInfo(withOwner: self.currentEmail, _title: str_title, content: str_content, targetPic: self.selectedPictureID, completionHandler: { (isAdded) in
                var dialog:AZDialogViewController!
                
                if isAdded {
                    self.stopAnimating()
                    self.startAnimating(message: "글 보내는 중", type: NVActivityIndicatorType.ballPulse)
                    self.firebaseDBHelper?.uploadArticleToStorage(withArticle: str_content, _filename: DocumentID, completionHandler: { (isUploaded) in
                        if isUploaded {
                            self.firebaseDBHelper?.appendArticleToUserInfo(withOwner: self.currentEmail, articleID: DocumentID, completionHandler: { (isUploaded) in
                                if isUploaded {
                                    self.firebaseDBHelper?.appendArticleToPictureInfo(withPictureID: self.selectedPictureID, articleID: DocumentID, completionHandler: { (isUploaded) in
                                        if isUploaded {
                                            dialog = AZDialogViewController(title: "보내기 성공", message: "글을 보냈습니다.")
                                            print("Article uploaded!")
                                        }else {
                                            dialog = AZDialogViewController(title: "보내기 실패", message: "다시 한 번 시도해주세요.")
                                            print("Failed to Upload!")
                                        }
                                        self.stopAnimating()
                                        dialog.show(in: self)
                                    })
                                }else {
                                    dialog = AZDialogViewController(title: "보내기 실패", message: "다시 한 번 시도해주세요.")
                                    print("Failed to Upload!")
                                    self.stopAnimating()
                                    dialog.show(in: self)
                                }
                            })
                        }else {
                            dialog = AZDialogViewController(title: "보내기 실패", message: "다시 한 번 시도해주세요.")
                            print("Failed to Upload!")
                            self.stopAnimating()
                            dialog.show(in: self)
                        }
                    })
                }else {
                    dialog = AZDialogViewController(title: "보내기 실패", message: "다시 한 번 시도해주세요.")
                    print("Failed to Add!")
                    self.stopAnimating()
                    dialog.show(in: self)
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
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
