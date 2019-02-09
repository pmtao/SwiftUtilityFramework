//
//  SlideCards.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/2/3.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import UIKit

open class SlideCards: UIView {
    @IBOutlet public weak var pageControl: UIPageControl!
    @IBOutlet public weak var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        let contentView = loadViewFromNib()
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight]
        
        addSubview(contentView!)
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    
    func loadViewFromNib() -> UIView! {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
//    func getCurrentPage() -> Int {
//        return max(Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width), 0)
//    }
}

//extension SlideCards: UIScrollViewDelegate {
//    
//    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        pageControl.currentPage = getCurrentPage()
//    }
//    
//    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        pageControl.currentPage = getCurrentPage()
//    }
//    
//}
