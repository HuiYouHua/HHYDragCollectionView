//
//  QMAnchorPrepareSelectedPhotoCell.swift
//  CollectionViewDrag
//
//  Created by 华惠友 on 2020/5/11.
//  Copyright © 2020 huayoyu.com. All rights reserved.
//

import UIKit

class QMAnchorPrepareSelectedPhotoCell: UICollectionViewCell {
    
    var photoImagView: UIImageView = UIImageView()
    var label: UILabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImagView)
        
        
        addSubview(label)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        photoImagView.frame = self.bounds
        
        
        label.frame = self.bounds
    }
    
}
