//
//  ViewController.swift
//  CollectionViewDrag
//
//  Created by 华惠友 on 2020/5/11.
//  Copyright © 2020 huayoyu.com. All rights reserved.
//

import UIKit
private let kCollectionID = "kCollectionID"

let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height

class ViewController: UIViewController {

    fileprivate var numbers: [Int] = []
    var sourceIndexPath : IndexPath?
    
    fileprivate lazy var collectionView: UICollectionView = {

        let layout = QMPhotoSelectedFlowLayout()
        layout.delegate = self
        layout.itemSize = CGSize(width: kScreenWidth / 2.0, height: kScreenWidth / 2.0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.register(QMAnchorPrepareSelectedPhotoCell.self, forCellWithReuseIdentifier: kCollectionID)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        
        for i in 0...100 {
            numbers.append(i)
        }
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGes)
    }
    
    
    @objc func longPressGesture(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: collectionView)
        
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: point) else {
                break
            }
            sourceIndexPath = selectedIndexPath

            let canMove = collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            if !canMove {
                break
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(point)
        case .ended:
//            if let targetSourceIndexPath = self.collectionView.indexPathForItem(at: point) {
//                let sourceData = numbers[sourceIndexPath!.item]
//                numbers.remove(at: sourceIndexPath!.item)
//                numbers.insert(sourceData, at: targetSourceIndexPath.item)
//            }
            collectionView.endInteractiveMovement()
        default:
            collectionView.endInteractiveMovement()
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCollectionID, for: indexPath) as! QMAnchorPrepareSelectedPhotoCell
        cell.contentView.backgroundColor = UIColor.randomColor()
        cell.label.text = String(numbers[indexPath.item])
//        cell.photoImagView.image = UIImage.init(named: numbers[indexPath.item] as! String ?? "1")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }

}

extension ViewController: QMPhotoSelectedFlowLayoutDelegate {
    func flowLayoutHeight(_ layout: QMPhotoSelectedFlowLayout, indexPath: IndexPath) -> CGFloat {
        switch indexPath.item {
        case 0:
            return 248
            case 1, 2:
            return 124
        default:
            return CGFloat(100 + indexPath.item)
        }
        
    }
    
    func exchangeItem(_ layout: QMPhotoSelectedFlowLayout, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = numbers.remove(at: sourceIndexPath.item)
        numbers.insert(temp, at: destinationIndexPath.item)
    }
}
