//
//  APFHorizontalAppListCell.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 5/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

var bundleListCellIdentifier: String = "BundleListCell"

class APFHorizontalBundleListCell: UICollectionViewCell {
    private var _icon: UIImage!
    
    
    var title: String = ""
    
    var icon: UIImage! {
        get {
            return _icon
        }
        set(img) {
            _icon = img
//            iconView.image = _icon
            UIGraphicsBeginImageContextWithOptions(iconView.bounds.size, false, UIScreen.mainScreen().scale)
            UIBezierPath(roundedRect: iconView.bounds, cornerRadius: 12.0).addClip()
            _icon.drawInRect(iconView.bounds)
            iconView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    var iconView: UIImageView!
    
    func create() {
        _icon = UIImage(named: "DefaultBundle")
        iconView = UIImageView(image: _icon)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        self.contentView.addSubview(iconView)
        
        let constraint_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|[iconView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["iconView": iconView])
        let constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:|[iconView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["iconView": iconView])
        
        self.contentView.addConstraints(constraint_H)
        self.contentView.addConstraints(constraint_V)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
