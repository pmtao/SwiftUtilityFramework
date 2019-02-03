//
//  SlideCardsCell.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2018/11/27.
//  Copyright © 2018 SinkingSoul. All rights reserved.
//

import UIKit

open class SlideCardsCell: UICollectionViewCell {
    open var backgroundImageView = UIImageView()
    open var backgroundShadowView = UIView()
    open var backgroundShadowColor = UIColor.clear
    private var latestCellBounds: CGRect? // 只用于判断是否有 bounds 更新
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        contentView.addSubview(backgroundShadowView)
        contentView.addSubview(backgroundImageView)
        self.clipsToBounds = false
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        contentView.addSubview(backgroundShadowView)
        contentView.addSubview(backgroundImageView)
        self.clipsToBounds = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open var bounds: CGRect {
        didSet {
            guard latestCellBounds != bounds else { return }
            latestCellBounds = bounds
            updateFrame()
        }
    }
    
    func updateFrame() {
        backgroundImageView.frame = self.bounds.insetBy(dx: 10, dy: 10)//(dx: 20, dy: 40)
        backgroundShadowView.frame = backgroundImageView.frame
        backgroundShadowView.backgroundColor = UIColor.white
        backgroundShadowView.layer.shadowColor = backgroundShadowColor.cgColor//UIColor(rgb: 0x194B5F).cgColor
        backgroundShadowView.layer.shadowOpacity = 0.4
        backgroundShadowView.layer.shadowOffset = CGSize(width: 0, height: 6)
        backgroundShadowView.layer.shadowRadius = 8
        addRadius(true)//false
    }
    
    open func addRadius(_ shouldAdd: Bool) {
        backgroundImageView.layer.cornerRadius = shouldAdd ? 10 : 0
        backgroundShadowView.layer.cornerRadius = shouldAdd ? 10 : 0
    }
    
}
