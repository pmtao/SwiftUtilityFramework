//
//  SlideCardsViewController.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2018/11/27.
//  Copyright © 2018 SinkingSoul. All rights reserved.
//

import UIKit

open class SlideCardsViewController: UIViewController {

    @IBOutlet weak public var collectionView: UICollectionView!
    @IBOutlet weak public var pageControl: UIPageControl!
    public var navigationRightButton: UIBarButtonItem?
    
    open var dataSource: SlideCardsDataSource!
    open var viewDelegate: SlideCardsViewDelegate!
    
    static var customCellIdentifier = "customCell"
    private var customCellClass: AnyClass?
    
    public static func new(dataSource: SlideCardsDataSource,
                           viewDelegate: SlideCardsViewDelegate,
                           customCellClass: AnyClass) -> SlideCardsViewController {
        let controller = SUFStoryboard.SlideCards.initialViewController() as SlideCardsViewController
        controller.dataSource = dataSource
        controller.viewDelegate = viewDelegate
        controller.customCellClass = customCellClass
        return controller
    }
    
    // MARK: --视图生命周期--
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        if customCellClass != nil {
            collectionView.register(customCellClass!, forCellWithReuseIdentifier: SlideCardsViewController.customCellIdentifier)
        }
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delaysContentTouches = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        viewDelegate.viewSetup(controller: self)
    }
    
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewDelegate.viewWillAppear(controller: self)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDelegate.viewDidAppear(controller: self)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewDelegate.viewWillDisappear(controller: self)
    }
    
    private var statusbarStyle: UIStatusBarStyle = .default {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return statusbarStyle
    }
    
}

// MARK: - 数据源与视图代理扩展

extension SlideCardsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int
    {
        return dataSource.numberOfItems()
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SlideCardsViewController.customCellIdentifier, for: indexPath)
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = dataSource.item(for: indexPath.item)
        
        if let customCellSetupBlock = dataSource.customCellSetupBlock {
            customCellSetupBlock(cell, item)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath)
    {
        
    }
}

// MARK: - ScrollView 代理方法扩展

extension SlideCardsViewController: UIScrollViewDelegate {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        for cell in self.collectionView.visibleCells {
//            (cell as! SlideCardsCell).addRadius(true)
//        }
    }

    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = getCurrentPage()
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        for cell in self.collectionView.visibleCells {
//            (cell as! SlideCardsCell).addRadius(true)
//        }
        pageControl.currentPage = getCurrentPage()
    }

}


// MARK: - 辅助方法

extension SlideCardsViewController {
    
    func getCurrentPage() -> Int {
        return max(Int(collectionView.contentOffset.x) / Int(collectionView.bounds.width), 0)
    }
}
