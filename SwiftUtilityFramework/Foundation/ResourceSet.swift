//
//  ResourceSet.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/1/18.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import UIKit

class EmptyClassForBundle {}

enum SUFStoryboard: String {
    case SlideCards
    
    
    func initialViewController<T>() -> T {
        let storyboard = UIStoryboard(name: self.rawValue, bundle: Bundle(for: EmptyClassForBundle.self))
        return storyboard.instantiateInitialViewController() as! T
    }
}

enum SUFCellIdentifier: String {
    case slideCardsCell
}
