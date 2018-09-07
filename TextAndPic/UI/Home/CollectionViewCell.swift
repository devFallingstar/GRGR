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
    var date = ""
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3.0
        self.clipsToBounds = false
        
//        imageview_pic.layer.borderWidth = 40
//        imageview_pic.layer.borderColor = UIColor.clear.cgColor
//        imageview_pic.layer.borderColor = UIColor.blue.cgColor
        imageview_pic = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
    
    public func configure(with model: CollectionViewCellModel) {
        imageview_pic.image = model.image
        self.date = model.date
    }
}
