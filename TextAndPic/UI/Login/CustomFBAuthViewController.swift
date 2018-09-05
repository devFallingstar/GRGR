//
//  CustomFBAuthViewController.swift
//  TextAndPic
//
//  Created by Fallingstar on 2018. 8. 29..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit
import FirebaseUI

class CustomFBAuthViewController: FUIAuthPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let testLabel = UILabel(frame: CGRect(x:0, y:0, width:width, height:height))
        testLabel.text = "Test Label"
        
        view.insertSubview(testLabel, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
