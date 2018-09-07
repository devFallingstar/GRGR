//
//  PostcardCollectionViewCell.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 9. 7..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit

class PostcardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var txtContent: UITextView!
    
    @IBOutlet weak var lbl_date: UILabel!
    @IBOutlet weak var lbl_nickname: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    
    public func configure(with model: PostcardModel) {
        
        if let font = UIFont(name: "KoPubBatangPM", size: 9) {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 10
            let attributes = [NSAttributedStringKey.font: font,
                              NSAttributedStringKey.paragraphStyle: style]
            txtContent.attributedText = NSAttributedString(string: model.content, attributes: attributes)
            
            lbl_date.attributedText = NSAttributedString(string: model.date, attributes: attributes)
            
            lbl_nickname.attributedText = NSAttributedString(string: model.nickname, attributes: attributes)
            
            lbl_title.attributedText = NSAttributedString(string: model.title, attributes: attributes)
        } else {
            print("Font not found!")
        }
        
        imageView.image = model.image
    }
}
