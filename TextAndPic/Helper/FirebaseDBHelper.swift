//
//  FirebaseDBHelper.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 8. 29..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseDBHelper {
    let collectionUser:CollectionReference?
    let collectionPics:CollectionReference?
    let collectionArtics:CollectionReference?
    
    init() {
        let db = Firestore.firestore()
        collectionUser = db.collection("collect_users")
        collectionPics = db.collection("collect_pics")
        collectionArtics = db.collection("collect_artics")
    }
    
    func addNewUser(withId _id:String!, _nickname:String!, _platform:String!, completionHandler:@escaping (_ isAdded:Bool) -> Void){
        let token = _id.toBase64()
        collectionUser?.document(token).setData([
            "id":_id,
            "nickname":_nickname,
            "platform":_platform,
            "profilePic":"",
            "description":"",
            "userArtics":[],
            "userPics":[],
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
    
    func getUserInfo(withId _id:String!, completionHandler:@escaping (_ isExist:Bool) -> Void){
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
}

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}
