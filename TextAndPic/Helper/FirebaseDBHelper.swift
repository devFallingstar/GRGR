//
//  FirebaseDBHelper.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 8. 29..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import Foundation
import Firebase

class FirebaseDBHelper {
    let collectionUser:CollectionReference!
    let collectionPics:CollectionReference!
    let collectionArtics:CollectionReference!
    let storagePics:StorageReference!
    let storageArtics:StorageReference!
    
    init() {
        let db = Firestore.firestore()
        let storage = Storage.storage().reference()
        
        collectionUser = db.collection("collect_users")
        collectionPics = db.collection("collect_pics")
        collectionArtics = db.collection("collect_artics")
        
        storagePics = storage.child("content_pictures/")
        storageArtics = storage.child("content_articles/")
    }
    
    func addNewUser(withId _id:String!, _nickname:String!, _platform:String!, completionHandler:@escaping (_ isAdded:Bool) -> Void){
        let token = _id.toBase64()
        collectionUser?.document(token).setData([
            "id":_id,
            "nickname":_nickname,
            "platform":_platform,
            "profilePic":"",
            "description":"",
            "userArtics" : {},
            "userPics" : {},
            "signupDate":"\(Date().ticks)",
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completionHandler(false)
            } else {
                print("Document successfully written!")
                completionHandler(true)
            }
        }
    }
    
    func getIfUserExist(withId _id:String!, completionHandler:@escaping (_ isExist:Bool) -> Void){
        let token = _id.toBase64()
        let docRef = collectionUser?.document(token)
        
        docRef?.getDocument { (document, error) in
            if let document = document, document.exists {
                print("Document exist")
                completionHandler(true)
            } else {
                print("Document does not exist")
                completionHandler(false)
            }
        }
    }
    
    
    func uploadPictureToStorage(withPicture _picture:UIImage!, _filename:String!,  completionHandler:@escaping (_ isUploaded:Bool) -> Void) {
        var imageData = Data()
        let imageRef = storagePics.child(_filename+".jpeg")
        imageData = UIImageJPEGRepresentation(_picture, 0.2)!
        
        imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else{
                print(error!)
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
    
    func addNewPictureInfo(withOwner _owner:String!, completionHandler:@escaping (_ isAdded:Bool) -> Void) -> String {
        var ref: DocumentReference! = nil
        ref = self.collectionPics.addDocument(data: [
            "articles" : [String:String](),
            "createDate" : "\(Date().ticks)",
            "filename" : "",
            "owner" : "\(_owner.toBase64())",
            "position" : arc4random_uniform(100)
        ]) { (error) in
            if error != nil {
                completionHandler(false)
            }else {
                self.collectionPics.document("\(ref!.documentID)").updateData([
                    "filename" : ref!.documentID], completion: { (error) in
                        if error != nil {
                            completionHandler(false)
                        }else {
                            completionHandler(true)
                        }
                })
            }
        }
        
        return ref.documentID
    }
    
    func appendPictureToUserInfo(withOwner _owner:String!, pictureID:String!, completionHandler:@escaping (_ isUploaded:Bool) -> Void) {
        collectionUser.document(_owner.toBase64()).updateData([
            "userPics."+pictureID : pictureID
        ]) { (error) in
            if error != nil {
                completionHandler(false)
            }else {
                completionHandler(true)
            }
        }
    }
    
    func getRandomPicturesID(completionHandler:@escaping (_ DocumentID:String) -> Void) {
        let queryRef:Query!
        
        queryRef = collectionPics.order(by: "position", descending: true)
        .limit(to: 3)
        
        queryRef.getDocuments { (snapshot, error) in
            for document in snapshot!.documents {
                self.collectionPics.document(document.documentID).updateData(["position" : arc4random_uniform(100)])
                
                completionHandler(document.documentID)
            }
        }
    }
    
    func getImageWithDownloadURL(withImageName _imageName:String!, completionHandler:@escaping (_ DownloadURL:UIImage) -> Void) {
        let imageRef = storagePics.child(_imageName+".jpeg")
        
        imageRef.getData(maxSize: 1024*1024*5) { (data, error) in
            print("Downloading IMAGE : \(_imageName)")
            if data != nil {
                let pic = UIImage(data: data!)
                completionHandler(pic!)
            }
        }
    }
    
    func getArticleInfo(withArticleID _articleID:String!, completionHandler:@escaping (_ ArticleInfo:Dictionary<String, String>) -> Void) {
        var ArticleInfo:Dictionary<String, String> = [String:String]()
        collectionArtics.document(_articleID).getDocument { (snapshot, error) in
            let title = snapshot?.get("title") as! String
            let filename = snapshot?.get("filename") as! String
            let date = snapshot?.get("createDate") as! Int
            let dateStr = String(millisecondsToDateString: date)
            let textRef = self.storageArtics.child(_articleID+".txt")
            
            textRef.getData(maxSize: 1024*1024*5) { (data, error) in
                print(filename)
                ArticleInfo["title"] = title
                ArticleInfo["filename"] = filename
                ArticleInfo["content"] = String(data: data!, encoding: String.Encoding.utf8)
                ArticleInfo["date"] = dateStr
                
                print("Date!!! : \(date)")
                print("Date!!! : \(dateStr)")
                
                completionHandler(ArticleInfo)
            }
        }
    }
    
    func addNewArticleInfo(withOwner _owner:String, _title:String, content:String, targetPic:String, completionHandler:@escaping (_ isAdded:Bool) -> Void) -> String {
        var ref: DocumentReference! = nil
        ref = collectionArtics.addDocument(data: [
            "createDate" : Date().ticks,
            "filename" : "",
            "owner" : _owner,
            "targetPic" : targetPic,
            "title" : _title
        ]) { (error) in
            if error != nil {
                completionHandler(false)
            }else {
                self.collectionArtics.document("\(ref!.documentID)").updateData([
                    "filename" : ref!.documentID
                    ], completion: { (error) in
                        if error != nil {
                            completionHandler(false)
                        }else {
                            completionHandler(true)
                        }
                })
            }
        }
        
        return ref.documentID
    }
    
    func uploadArticleToStorage(withArticle _article:String!, _filename:String!,  completionHandler:@escaping (_ isUploaded:Bool) -> Void) {
        let txtRef = storageArtics.child(_filename+".txt")
        let txtData = Data(_article.utf8)
        
        txtRef.putData(txtData, metadata: nil) { (metadata, error) in
            guard metadata != nil else{
                print(error!)
                completionHandler(false)
                return
            }
            completionHandler(true)
        }
    }
    
    func appendArticleToUserInfo(withOwner _owner:String!, articleID:String!, completionHandler:@escaping (_ isUploaded:Bool) -> Void) {
        collectionUser.document(_owner.toBase64()).updateData([
            "userArtics."+articleID : articleID
        ]) { (error) in
            if error != nil {
                completionHandler(false)
            }else {
                completionHandler(true)
            }
        }
    }
    
    func appendArticleToPictureInfo(withPictureID _pictureID:String!, articleID:String!, completionHandler:@escaping (_ isUploaded:Bool) -> Void) {
        collectionPics.document(_pictureID).updateData([
            "articles."+articleID : articleID
        ]) { (error) in
            if error != nil {
                completionHandler(false)
            }else {
                completionHandler(true)
            }
        }
    }
    
    func getArticles(WithImageId _imageId:String, completionHandler:@escaping (_ Articles:Array<String>) -> Void) {
        collectionPics.document(_imageId).getDocument { (snapshot, error) in
            // TODO
            self.collectionPics.document(_imageId).getDocument(completion: { (snapshot, error) in
                var Articles:Array<String> = []
                let map_articles:[String:String] = snapshot?.get("articles") as! [String : String]
                for (each_key, _) in map_articles {
                    Articles.append(each_key)
                }
                print("Map Articles : \(Articles)")
                completionHandler(Articles)
            })
        }
    }
}
