//
//  QMPhotoSelectedFlowLayout.swift
//  CollectionViewDrag
//
//  Created by 华惠友 on 2020/5/11.
//  Copyright © 2020 huayoyu.com. All rights reserved.
//

import UIKit

@objc protocol QMPhotoSelectedFlowLayoutDelegate: class {
    /// cell的高度
    func flowLayoutHeight(_ layout : QMPhotoSelectedFlowLayout, indexPath : IndexPath) -> CGFloat
    /// 几列
    @objc optional func numberOfColsInFallLayout(_ layout : QMPhotoSelectedFlowLayout) -> Int
    /// 交换数据源
    @objc optional func exchangeItem(_ layout : QMPhotoSelectedFlowLayout, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

class QMPhotoSelectedFlowLayout: UICollectionViewFlowLayout {
    
    weak var delegate : QMPhotoSelectedFlowLayoutDelegate?
    
    fileprivate lazy var attrsArray : [UICollectionViewLayoutAttributes] = [UICollectionViewLayoutAttributes]()
    fileprivate lazy var colHeights : [CGFloat] = {
        let cols = delegate?.numberOfColsInFallLayout?(self) ?? 2
        var colHeights = Array(repeating: sectionInset.top, count: cols)
        return colHeights
    }()
    
    fileprivate var maxH : CGFloat = 0
    var unionRects : NSMutableArray = NSMutableArray()
    let unionSize = 20 // 确定并集frame区间,一个屏幕20个cell够用了
    
    override func prepare() {
        super.prepare()
        
        unionRects.removeAllObjects()
        attrsArray.removeAll()
        let cols = delegate?.numberOfColsInFallLayout?(self) ?? 2
        colHeights = Array(repeating: sectionInset.top, count: cols)
        maxH = 0
        
        let itemCount = collectionView!.numberOfItems(inSection: 0)
        let itemW = (collectionView!.bounds.width - sectionInset.left - sectionInset.right - minimumInteritemSpacing) / CGFloat(cols)
        
        for i in 0..<itemCount {
            // 1.设置每一个Item位置相关的属性
            let indexPath = IndexPath(item: i, section: 0)
            
            // 2.根据位置创建Attributes属性
            let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            
            // 3.高度
            guard let height = delegate?.flowLayoutHeight(self, indexPath: indexPath) else {
                fatalError("请设置数据源,并且实现对应的数据源方法")
            }
            
            // 4.取出最小列的位置
            var minH: CGFloat = colHeights.min()!
            let index = colHeights.firstIndex(of: minH)!
            minH = minH + height + minimumLineSpacing
            colHeights[index] = minH
            
            // 5.设置item的属性
            attrs.frame = CGRect(x: sectionInset.left + (minimumInteritemSpacing + itemW) * CGFloat(index), y: minH - height - minimumLineSpacing, width: itemW, height: height)
            attrsArray.append(attrs)
        }
        maxH = colHeights.max()!
        
        var idx = 0;
        let itemCounts = attrsArray.count
        while(idx < itemCounts){
            let rect1 = (attrsArray[idx]).frame as CGRect
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = (attrsArray[idx]).frame as CGRect
            var unionRect = rect1.union(rect2)
            unionRect.origin.x = 0
            unionRect.size.width = collectionView!.frame.width
            // 获得修改布局的区间frame
            unionRects.add(NSValue(cgRect:unionRect))
            idx += 1
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.item >= attrsArray.count{
            return nil
        }
        return attrsArray[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin = 0, end = unionRects.count
        let attrs = NSMutableArray()
        
        for i in 0 ..< end {
            if rect.intersects((unionRects.object(at: i) as AnyObject).cgRectValue){
                begin = i * unionSize;
                break
            }
        }
        for i in (0 ..< unionRects.count).reversed() {
            if rect.intersects((unionRects.object(at: i) as AnyObject).cgRectValue){
                end = min((i+1)*unionSize,attrsArray.count)
                break
            }
        }
        
        // 拖拽的那个点跟某个cell的frame有交集则更新布局
        for i in begin ..< end {
            let attr = attrsArray[i]
            if rect.intersects(attr.frame) {
                attrs.add(attr)
            }
        }
        return NSArray(array: attrs) as? [UICollectionViewLayoutAttributes]
    }
    
    override var collectionViewContentSize: CGSize {
        var contentSize = collectionView!.bounds.size as CGSize
        contentSize.height = maxH + sectionInset.bottom - minimumLineSpacing
        return  contentSize
    }
    
    override func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
        let oldBounds = collectionView!.bounds
        if newBounds.width != oldBounds.width{
            return true
        }
        return false
    }
    
    override func invalidationContext(forInteractivelyMovingItems targetIndexPaths: [IndexPath], withTargetPosition targetPosition: CGPoint, previousIndexPaths: [IndexPath], previousPosition: CGPoint) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forInteractivelyMovingItems: targetIndexPaths, withTargetPosition: targetPosition, previousIndexPaths: previousIndexPaths, previousPosition: previousPosition)
        delegate?.exchangeItem?(self, moveItemAt: previousIndexPaths[0], to: targetIndexPaths[0])
        
        return context
    }
}
