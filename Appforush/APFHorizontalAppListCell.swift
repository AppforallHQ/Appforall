//
//  APFHorizontalAppListCell.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 5/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

var appListCellIdentifier: String = "HorizontalAppListCell"

class APFHorizontalAppListCell: UICollectionViewCell {
    private var _icon: UIImage!
    private var _title: String = ""
    private var _size: String = ""
    
    var title: String {
        get {
            return _title
        }
        set(text) {
            _title = text
            
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.lineHeightMultiple = 0.9
            titleStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            titleStyle.alignment = .Center
            
            let titleAttrString = NSMutableAttributedString(string: _title)
            titleAttrString.addAttribute(NSParagraphStyleAttributeName, value: titleStyle, range: NSMakeRange(0, titleAttrString.length))
            titleAttrString.addAttribute(NSParagraphStyleAttributeName, value: titleStyle, range: NSMakeRange(0, titleAttrString.length))
            
            titleLabel?.attributedText = titleAttrString
        }
    }
    
    var size: String {
        get {
            return _size
        }
        set(s) {
            _size = s
            sizeLabel?.text = _size //NSByteCountFormatter.stringFromByteCount(_size, countStyle: NSByteCountFormatterCountStyle.File)
        }
    }
    
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
    var titleLabel: UILabel!
    var sizeLabel: UILabel!
    
    func create() {
        _icon = UIImage(named: "Icon160_1.jpg")
        iconView = UIImageView(image: _icon)
        titleLabel = UILabel()
        sizeLabel = UILabel()
        
//        var iconLayer = iconView.layer
//        iconLayer.masksToBounds = true
//        iconLayer.shouldRasterize = true
//        iconLayer.cornerRadius = 12.0
        
        titleLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 12.0)
        sizeLabel.font = UIFont(name: "HelveticaNeue-Light", size: 10.0)
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColorFromHex("#666666")
        
        sizeLabel.textAlignment = .Center
        sizeLabel.textColor = UIColorFromHex("#999999")
        
        titleLabel.preferredMaxLayoutWidth = 80.0
        
        //titleLabel.text = self.title
        //sizeLabel.text = NSByteCountFormatter.stringFromByteCount(self.size, countStyle: NSByteCountFormatterCountStyle.File)
        
        titleLabel.numberOfLines = 2
        sizeLabel.numberOfLines = 1
        
        self.contentView.addSubview(iconView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(sizeLabel)
        
        var constraint_H = NSLayoutConstraint.constraintsWithVisualFormat("H:[iconView(80)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["iconView": iconView])
        let constraint_V = NSLayoutConstraint.constraintsWithVisualFormat("V:[iconView(80)]", options: NSLayoutFormatOptions(), metrics: nil, views: ["iconView": iconView])
        
        iconView.addConstraints(constraint_H)
        iconView.addConstraints(constraint_V)
        
        constraint_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|[titleLabel(80)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["titleLabel": titleLabel])
        
        //titleLabel.addConstraints(constraint_H)
        self.contentView.addConstraints(constraint_H)
        
        constraint_H = NSLayoutConstraint.constraintsWithVisualFormat("H:|[sizeLabel(80)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["sizeLabel": sizeLabel])
        
        //sizeLabel.addConstraints(constraint_H)
        self.contentView.addConstraints(constraint_H)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iconView]-7-[titleLabel]-1-[sizeLabel]", options: NSLayoutFormatOptions(), metrics: nil, views: ["iconView": iconView, "titleLabel": titleLabel, "sizeLabel": sizeLabel]))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        create()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
