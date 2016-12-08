//
//  APFPadAppCollectionViewCell.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 22/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}

class APFPadAppCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cellHRuleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var appStatusActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var availabilityIcon: UIImageView!

    @IBOutlet weak var infoIcon: UIImageView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var appExtraInfo: UILabel!
    
    @IBOutlet weak var starRating: EDStarRating!
    @IBOutlet weak var ratingCount: UILabel!
    
    @IBOutlet weak var actionButton : UIButton!
    @IBOutlet weak var categoryOfApp : UILabel!
    
    var Action: String! = "None"
    
    var isCategory: Bool = false
    
    var _icon: UIImage!
    var _category: String!
    
    var icon: UIImage! {
        get {
            return _icon
        }
        
        set(img) {
            if !isCategory {
                _icon = img
                
                if _icon == nil {
                    return
                }
                
                UIGraphicsBeginImageContextWithOptions(iconView.bounds.size, false, UIScreen.mainScreen().scale)
                UIBezierPath(roundedRect: iconView.bounds, cornerRadius: 14.0).addClip()
                _icon.drawInRect(iconView.bounds)
                iconView.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            else {
                _icon = img
                iconView.image = _icon
            }
        }
    }
    
    func setEntryData(entry: APFAppEntry)
    {
        if entry.averageUserRating > 0.0
        {
            self.ratingCount.text = String(format: "(%d)", arguments: [entry.userRatingCount])
            self.ratingCount.hidden = false
            self.starRating.rating = entry.averageUserRating
            self.starRating.hidden = false
        }
        else
        {
            self.ratingCount.hidden = true
            self.starRating.hidden = true
        }
        
        self.categoryOfApp.hidden = true
        for category in APFPadAppCollectionViewController.categories {
            if entry.applicationCategory == category["CellFeed"] as! String {
                self.categoryOfApp.text = category["CellText"] as? String
                self.categoryOfApp.hidden = false
            }
        }
        
        if entry.availableInPROJECT == true
        {
            if APFPROJECTAPI.currentInstance().isApplicationInstalled(entry.applicationiTunesIdentification)
            {
                self.Action = "Open"
                self.actionButton.backgroundColor = self.backgroundColor
                self.actionButton.layer.borderColor = UIColorFromHex("959595").CGColor
                self.actionButton.layer.borderWidth = 1.0
                self.actionButton.setTitleColor(UIColorFromHex("959595"), forState: UIControlState.Normal)
                self.actionButton.setTitle("اجرا", forState: .Normal)
            }
            else
            {
                self.Action = "Download"
                self.actionButton.backgroundColor = UIColor.userBlue()
                self.actionButton.layer.borderWidth = 0.0
                self.actionButton.setTitleColor(UIColorFromHex("FFFFFF"), forState: UIControlState.Normal)
                self.actionButton.setTitle("دانلود",forState: .Normal)
            }
        }
        else
        {
            self.Action = "Purchase"
            self.actionButton.setTitleColor(UIColorFromHex("FFFFFF"), forState: UIControlState.Normal)
            self.actionButton.backgroundColor = UIColor.userGreen()
            self.actionButton.layer.borderWidth = 0.0
            if entry.iranPrice > 0
            {
                let eng = "0123456789"
                let fa = "۰۱۲۳۴۵۶۷۸۹"
                
                let nf = NSNumberFormatter()
                var original = String(format: "%@ تومان",nf.stringFromNumber(entry.iranPrice)!)
                
                for (i,w) in eng.characters.enumerate() {
                    original = original.stringByReplacingOccurrencesOfString(eng[i], withString: fa[i])
                }
                
                self.actionButton.setTitle(original, forState: .Normal)
            }
            else if entry.iranPrice == 0
            {
                self.Action = "None"
                self.actionButton.setTitle("دانلود", forState: .Normal)
            }
            else
            {
                self.actionButton.setTitle("خرید", forState: .Normal)
            }
        }
        
    }
    
    var category: String! {
        get {
            return _category
        }
        
        set(catName) {
            _category = catName
            self.categoryLabel.text = _category
            self.categoryLabel.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if self.cellHRuleHeightConstraint != nil {
            self.cellHRuleHeightConstraint.constant = 1 / UIScreen.mainScreen().scale
        }
    }
    
    func setData(title: String, downloads: NSNumber, size: String, category: String) {
        let data = "\(downloads)  /  \(size)  / \(category)"
        self.infoLabel.text = data
        self.titleLabel.text = title
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        UIImage(named: "AppBg")?.drawInRect(rect)
    }

    
}
