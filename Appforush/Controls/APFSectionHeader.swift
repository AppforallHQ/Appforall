//
//  APFSectionHeader.swift
//  PROJECT
//
//  Created by Sadjad Fouladi on 4/1/94.
//  Copyright (c) 1394 AP PROJECT. All rights reserved.
//

import UIKit

class APFSectionHeader: UIControl {

    var color: UIColor! = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    var text: String!
    var label: UILabel!
    var link: String!
    var moreButton: UIButton!
    var moreButtonChevron: UIButton!
    var viewController: UIViewController!
    
    convenience init(text: String, color: UIColor, link: String?, viewController: UIViewController?) {
        self.init()
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
        
        self.viewController = viewController
        self.text = text
        self.color = color
        self.link = link
        
        self.label = UILabel()//frame: CGRectMake(0, 0, 320, 20))
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label?.font = UIFont(name: "IRANSans", size: 14.0)
        self.label?.textColor = UIColor(white: 119.0/255, alpha: 1.0)
        self.label?.textAlignment = NSTextAlignment.Right
        self.label?.text = self.text

        addSubview(self.label)
        self.label.sizeToFit()
        
        self.moreButton = UIButton(type: UIButtonType.Custom)
        self.moreButton.translatesAutoresizingMaskIntoConstraints = false
        self.moreButton.setImage(UIImage(named: "MoreButton"), forState: UIControlState.Normal)
        //self.moreButton.setTitle("ادامه", forState: UIControlState.Normal)
        //self.moreButton.titleLabel?.font = UIFont(name: "IRANSans", size: 10.0)
        //self.moreButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        //self.moreButton.backgroundColor = UIColor(red: 69.0/255, green: 155.0/255, blue: 235.0/255, alpha: 1.0)
        //self.moreButton.layer.cornerRadius = 5.0
        //self.moreButton.setTitleColor(UIColor(white: 0.6, alpha: 1.0), forState: UIControlState.Normal)
        //self.moreButton.setTitleColor(self.color.colorWithAlphaComponent(0.7), forState: .Normal)
        //self.moreButton.layer.borderWidth = 1.0
        //self.moreButton.layer.borderColor = self.viewController.view.tintColor.CGColor // self.color.colorWithAlphaComponent(0.7).CGColor
        
//        var insets = self.moreButton.contentEdgeInsets
//        insets.top += 8
//        insets.bottom += 8
//        insets.right += 10
//        insets.left += 10
//        self.moreButton.contentEdgeInsets = insets
        
        addSubview(self.moreButton)
        //self.moreButton.setContentHuggingPriority(1.0, forAxis: UILayoutConstraintAxis.Horizontal)
        //self.moreButton.setContentHuggingPriority(1.0, forAxis: UILayoutConstraintAxis.Vertical)
        //self.moreButton.setContentCompressionResistancePriority(1000.0, forAxis: UILayoutConstraintAxis.Horizontal)
        //self.moreButton.setContentCompressionResistancePriority(1000.0, forAxis: UILayoutConstraintAxis.Vertical)
        
        let hrule = UIView()
        hrule.translatesAutoresizingMaskIntoConstraints = false
        hrule.backgroundColor = UIColor(white: 245.0/255, alpha: 1.0)
        addSubview(hrule)
        
        let constraints_H_1 = NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(hSpacing)-[button(80.0)]-5-[label]-15-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label, "button": moreButton])
        let constraints_H_2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[hrule]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["hrule": hrule])
        let constraints_V_1 = NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[button(23.0)]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label, "button": moreButton])
        let constraints_V_2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]-0-[hrule(1.0)]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["label": label, "hrule": hrule])
        
        addConstraints(constraints_H_1)
        addConstraints(constraints_H_2)
        addConstraints(constraints_V_1)
        addConstraints(constraints_V_2)
        
        if self.link == nil {
            self.moreButton.hidden = true
        }
        else {
            self.moreButton.addTarget(self, action: "showMoreApps:", forControlEvents: UIControlEvents.TouchDown)
        }
    }
    
//    override init() {
//        super.init()
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        self.opaque = true
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        /*var height: CGFloat = rect.height
        var width: CGFloat = rect.width
        var startX: CGFloat = width - 20.0
        var context = UIGraphicsGetCurrentContext()

        for i in 0...2 {
            var startY: CGFloat = CGFloat(i) * 7.5
            var rectangle = CGRectMake(startX, startY, 20.0, 5.0)
            CGContextSetFillColorWithColor(context, self.color.CGColor)
            CGContextFillRect(context, rectangle)
        }*/
    }
    
    func showMoreApps(sender: UIButton!) {
        let appCollectionViewController = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("AppCollection") as! APFPadAppCollectionViewController
        appCollectionViewController.title = self.text
        appCollectionViewController.collectionType = .AppList
        appCollectionViewController.getAppEntries[0] = { (page: NSInteger) -> [AnyObject]! in
            return APFPROJECTAPI.currentInstance().getAppListByURL(self.link, page: page)
        }
        
        self.viewController.navigationController?.pushViewController(appCollectionViewController, animated: true)
    }
}
