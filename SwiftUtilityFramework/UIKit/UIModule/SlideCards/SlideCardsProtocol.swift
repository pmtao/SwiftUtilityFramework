//
//  CardsProtocol.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2018/11/27.
//  Copyright © 2018 SinkingSoul. All rights reserved.
//

import UIKit

public protocol SlideCardsItem {}

public protocol SlideCardsDataSource: class {
    var customCellSetupBlock: ((UICollectionViewCell, SlideCardsItem) -> Void)? { get }
    
    /// CardSliderItem for the card at given index, counting from the top.
    func item(for index: Int) -> SlideCardsItem
    
    /// Total number of cards.
    func numberOfItems() -> Int
}

public protocol SlideCardsViewDelegate: class {
    var customCellSetupBlock: ((UICollectionViewCell, SlideCardsItem) -> Void)? { get }
    
    func viewSetup(controller: SlideCardsViewController)
    
    func viewWillAppear(controller: UIViewController)
    func viewDidAppear(controller: UIViewController)
    func viewWillDisappear(controller: UIViewController)
}

//protocol ShadedCardCell {
//    func setShadeOpacity(progress: CGFloat)
//    func setZoom(progress: CGFloat)
//}
//
//@objc protocol SlideCardsLayoutDelegate: class {
//    func transition(between currentIndex: Int, and nextIndex: Int, progress: CGFloat)
//}
