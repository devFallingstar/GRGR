//
//  CollectionViewCell.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 9. 5..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageview_pic: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        self.clipsToBounds = false
        
        imageview_pic = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
}
