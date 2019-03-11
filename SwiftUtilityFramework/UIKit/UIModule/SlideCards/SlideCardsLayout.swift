//
//  SlideCardsLayout.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2018/11/27.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import UIKit

open class SlideCardsLayout: UICollectionViewLayout {

    // MARK: --便利计算属性--
    
    public var itemSize: CGSize = .zero {
        didSet { invalidateLayout() }
    }
    
    public var itemsCount: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }
    
    public var collectionBounds: CGRect {
        return collectionView!.bounds
    }
    
    public var contentOffset: CGPoint {
        return collectionView!.contentOffset
    }
    
    public var currentPage: Int {
        return max(Int(contentOffset.x) / Int(collectionBounds.width), 0)
    }
    
    // MARK: --存储属性--
    
    open var contentBounds = CGRect.zero
    open var cachedAttributes = [UICollectionViewLayoutAttributes]()
    
    
    // MARK: --自定义布局方法--
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let maxBoundsX = collectionBounds.size.width * CGFloat(itemsCount - 1)
        let minBoundsX: CGFloat = 0
        if newBounds.origin.x > maxBoundsX || newBounds.origin.x < minBoundsX {
            return false
        } else {
            return true
        }
//        return !newBounds.size.equalTo(collectionBounds.size)
    }
    
    open override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        
        cachedAttributes.removeAll()
        contentBounds = CGRect(origin: .zero, size: cv.bounds.size)
        
        let width = collectionBounds.width
        let height = collectionBounds.height
        itemSize = CGSize(width: width, height: height)
        
        createAtributes()
    }
    
    override open var collectionViewContentSize: CGSize {
        return contentBounds.size
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }
    
    override open func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]?
    {
        return cachedAttributes.filter() { (attributes: UICollectionViewLayoutAttributes) -> Bool in
            return rect.intersects(attributes.frame)
        }
    }
    
    // MARK: --辅助计算方法--
    
    func layoutAttributes(for index: Int) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith:IndexPath(item: index, section: 0))
        attributes.size = itemSize
        let fixedOffset = contentOffset.x + collectionBounds.width - itemSize.width / 2//CGFloat(index) * collectionBounds.width
        if index <= currentPage {
            attributes.center = CGPoint(x: fixedOffset, y: collectionBounds.midY)
        } else {
            let offset = CGFloat(index - currentPage) * collectionBounds.width - CGFloat(Int(contentOffset.x) % Int(collectionBounds.width))
            attributes.center = CGPoint(x: fixedOffset + offset, y: collectionBounds.midY)
            
        }
        let offset = CGFloat(Int(contentOffset.x) % Int(collectionBounds.width))
        let offsetProgress = CGFloat(offset) / collectionBounds.width
        if index <= currentPage && offsetProgress > 0 {
            let scale: CGFloat = 0.8 + 0.2 * (1 - offsetProgress)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        if index < currentPage {
            attributes.size = CGSize(width: itemSize.width * 0.8, height: itemSize.height * 0.8)
        }
        return attributes
    }
    
    func createAtributes() {
        print("SlideCardsLayout createAtributes.")
        for index in 0..<itemsCount {
            let attribute = layoutAttributes(for: index)
            cachedAttributes.append(attribute)
        }
        contentBounds.size = CGSize(width: collectionBounds.width * CGFloat(itemsCount),
                                    height: collectionBounds.height)
        
        
    }
    
    
}


