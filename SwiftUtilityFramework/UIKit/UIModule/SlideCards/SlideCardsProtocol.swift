//
//  CardsProtocol.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2018/11/27.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import UIKit

public protocol SlideCardsItem {}

public protocol SlideCardsDataSource: class {
    
    /// CardSliderItem for the card at given index, counting from the top.
    func item(for index: Int) -> SlideCardsItem
    
    /// Total number of cards.
    func numberOfItems() -> Int
}

