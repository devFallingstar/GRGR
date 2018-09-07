//
//  HomeViewController
//  TextAndPic
//
//  Created by Fallingstar on 2018. 8. 29..
//  Copyright © 2018년 Fallingstar. All rights reserved.
//

import UIKit
import FirebaseAuth
import ALCameraViewController
import NVActivityIndicatorView
import AZDialogView


class HomeViewController: UIViewController, NVActivityIndicatorViewable {
    var currentUser:User?
    var cellWidth:CGFloat!
    var cellHeight:CGFloat!
    var firebaseDBHelper:FirebaseDBHelper?
    var activityIndicatorView:NVActivityIndicatorView!
    
    var date_list = ["2018.08.06", "2018.12.29", "2018.07.29", "2018.11.11"]
    var pictures_list:Array<UIImage>!
    
    @IBOutlet weak var HomeCollectionView: UICollectionView!
    @IBOutlet weak var lbl_date: UILabel!
    
    let itemColors = [UIColor.red, UIColor.yellow, UIColor.blue, UIColor.green]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initDBInformation()
        initHomeListItems()
    }
    
    func initUI() {
        cellWidth = view.frame.width - 70
        cellHeight = cellWidth*3 / 4
        
        print("Widht : \(cellWidth), Height : \(cellHeight)")
        
        let insetX = (HomeCollectionView.bounds.width - cellWidth) / 2.0
        let insetY = (HomeCollectionView.bounds.height - cellHeight) / 2.0
        
        let layout = HomeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 45
        layout.scrollDirection = .horizontal
        
        HomeCollectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        HomeCollectionView.delegate = self
        HomeCollectionView.dataSource = self
        
        HomeCollectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        lbl_date.text = date_list[0]
    }
    
    func initDBInformation() {
        self.firebaseDBHelper = FirebaseDBHelper()
    }
    
    func initHomeListItems() {
        self.pictures_list = []
        firebaseDBHelper?.getRandomPicturesID(completionHandler: { (documentID) in
//            print("Document ID : \(documentID)")
            
            self.firebaseDBHelper?.getImageWithDownloadURL(withImageName: documentID, completionHandler: { (image) in
                self.pictures_list.append(image)
                self.HomeCollectionView.reloadData()
            })
        })
    }
    
    @IBAction func onCameraBtnClicked(_ sender: Any) {
        let cameraViewController = CameraViewController { [weak self] image, asset in
            var DocumentID:String!
            var currentEmail : String!
            currentEmail = self?.currentUser?.email
            
            self?.startAnimating(message: "엽서 작성 중", type: NVActivityIndicatorType.ballPulse)
            
            DocumentID = self?.firebaseDBHelper?.addNewPictureInfo(withOwner: currentEmail, completionHandler: { (isAdded) in
                var dialog:AZDialogViewController!
                if isAdded {
                    self?.stopAnimating()
                    self?.startAnimating(message: "엽서 띄우는 중", type: NVActivityIndicatorType.ballPulse)
                    
                    self?.firebaseDBHelper?.uploadPictureToStorage(withPicture: image, _filename: DocumentID, completionHandler: { (isUploaded) in
                        if isUploaded {
                            self?.firebaseDBHelper?.appendPictureToUserInfo(withOwner: currentEmail, pictureID: DocumentID, completionHandler: { (isUploaded) in
                                if isUploaded {
                                    dialog = AZDialogViewController(title: "띄우기 성공", message: "엽서를 띄웠습니다.")
                                    print("Uploaded!")
                                }else {
                                    dialog = AZDialogViewController(title: "띄우기 실패", message: "다시 한 번 시도해주세요.")
                                    print("Failed to Upload!")
                                }
                                self?.stopAnimating()
                                dialog.show(in: self!)
                            })
                        }else {
                            dialog = AZDialogViewController(title: "띄우기 실패", message: "다시 한 번 시도해주세요.")
                            print("Failed to Upload!")
                            self?.stopAnimating()
                            dialog.show(in: self!)
                        }
                    })
                }else {
                    dialog = AZDialogViewController(title: "띄우기 실패", message: "다시 한 번 시도해주세요.")
                    print("Failed to Add!")
                    self?.stopAnimating()
                    dialog.show(in: self!)
                }
            })
            
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures_list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell

        if cell.imageview_pic != nil {
            cell.backgroundColor = itemColors[indexPath.row]
            cell.imageview_pic!.image = self.pictures_list[indexPath.row]
            cell.imageview_pic!.frame.size.width = cellWidth
            cell.imageview_pic!.frame.size.height = cellHeight
        }
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let itemsIndices = self.HomeCollectionView.indexPathsForVisibleItems
        let firstIndex = itemsIndices[0][1]
        
        lbl_date.text = date_list[firstIndex]
    }
}

extension HomeViewController : UIScrollViewDelegate
{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        // item의 사이즈와 item 간의 간격 사이즈를 구해서 하나의 item 크기로 설정.
        let layout = self.HomeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        // targetContentOff을 이용하여 x좌표가 얼마나 이동했는지 확인
        // 이동한 x좌표 값과 item의 크기를 비교하여 몇 페이징이 될 것인지 값 설정
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        var roundedIndex = round(index)
        
        // scrollView, targetContentOffset의 좌표 값으로 스크롤 방향을 알 수 있다.
        // index를 반올림하여 사용하면 item의 절반 사이즈만큼 스크롤을 해야 페이징이 된다.
        // 스크로로 방향을 체크하여 올림,내림을 사용하면 좀 더 자연스러운 페이징 효과를 낼 수 있다.
        if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            roundedIndex = floor(index)
        } else {
            roundedIndex = ceil(index)
        }
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}


