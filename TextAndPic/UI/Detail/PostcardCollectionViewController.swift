//
//  PostcardCollectionViewController.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 9. 6..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit
import Floaty
import FirebaseAuth

class PostcardCollectionViewController: UIViewController {
    var selectedPictureID:String!
    var currentEmail:String!
    var currentUser:User!
    var firebaseDBHelper:FirebaseDBHelper?
    var articles:Array<String> = []
    var cellModels:Array<PostcardModel> = []

    @IBOutlet weak var PostcardCollectionView: UICollectionView!
    @IBOutlet weak var lbl_noArticlesContents: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_nickname: UILabel!
    @IBOutlet weak var lbl_date: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initDBInformation()
        initCellData()
    }
    
    func initUI() {
        let floaty = Floaty()
        print(selectedPictureID)
        floaty.addItem(title: "새 글 작성") { (item) in
            self.performSegue(withIdentifier: "postcard_collection_to_post_writing", sender: nil)
        }
        self.view.addSubview(floaty)
        PostcardCollectionView.delegate = self
        PostcardCollectionView.dataSource = self
    }
    
    func initDBInformation() {
        self.firebaseDBHelper = FirebaseDBHelper()
    }
    
    func initCellData() {
        articles = []
        self.firebaseDBHelper?.getArticles(WithImageId: selectedPictureID, completionHandler: { (articles) in
            self.articles = articles
            
            self.cellModels = []
            for each_articleID in self.articles {
                print("Selected PIC ID \(self.selectedPictureID)")
                self.firebaseDBHelper?.getImageWithDownloadURL(withImageName: self.selectedPictureID, completionHandler: { (image) in
                    print("IMAGe : \(self.selectedPictureID)")
                    
                    self.firebaseDBHelper?.getArticleInfo(withArticleID: each_articleID, completionHandler: { (articleInfo) in
                        let newPostCardModel = PostcardModel(image: image, content: articleInfo["content"]!,
                                                             title: articleInfo["title"]!, nickname: self.currentUser.displayName!, date: articleInfo["date"]!)
                        self.cellModels.append(newPostCardModel)
                        
                        print("Each Article ID \(each_articleID)")
                        print("\(self.articles.count) | \(self.cellModels.count)")
                        
                        if self.articles.count == self.cellModels.count {
                            self.PostcardCollectionView.reloadData()
                            self.lbl_noArticlesContents.isHidden = true
                            print("Number of items\(self.PostcardCollectionView.numberOfItems(inSection: 0))")
                            print("ASDF!")
                        }
                    })
                })
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBackBtnClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postcard_collection_to_post_writing" {
            if let destinationVC = segue.destination as? PostWritingViewController {
                destinationVC.selectedPictureID = self.selectedPictureID
                destinationVC.currentEmail = self.currentEmail
            }
        }
    }

}

extension PostcardCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "postcardViewCell", for: indexPath) as! PostcardCollectionViewCell
        
        cell.configure(with: self.cellModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
