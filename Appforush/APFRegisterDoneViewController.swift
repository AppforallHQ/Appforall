//
//  APFRegisterViewController.swift
//  PROJECT
//
//  Created by Amir on 9/27/15.
//  Copyright © 2015 PROJECT. All rights reserved.
//

import UIKit

@objc class APFRegisterDoneViewController : UIViewController{
    
    @IBOutlet weak var backgroundView : UIImageView!;
    @IBOutlet weak var loginView : UIView!;
    
    
    @IBOutlet weak var sendEmailButton : UIButton!;
    @IBOutlet weak var loginButton : UIButton!;
    
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!;
    
    var parent : UIViewController!
    
    
    var initialY : CGFloat!;
    var initialSize : CGFloat!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let height : CGFloat = UIScreen.mainScreen().bounds.size.height;
        
        if(Double.abs(Double.init(height) - 480.0) < Foundation.DBL_EPSILON) { // iPhone 4s
            bottomConstraint.constant = 25;
        }
        if(Double.abs(Double.init(height) - 568.0) < Foundation.DBL_EPSILON) { // iPhone 5/5C/5S
            bottomConstraint.constant = 40;
        }
        
        self.loginButton.layer.cornerRadius = 4.0;
        
        if(UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            
            if(Double.abs(Double.init(height) - 568.0) < Foundation.DBL_EPSILON) { // iPhone 5/5C/5S
                self.backgroundView.image = UIImage.init(named:"LaunchImage-700-568h@2x.png");
            }
            else if(Double.abs(Double.init(height) - 667.0) < Foundation.DBL_EPSILON) { // iPhone 6
                self.backgroundView.image = UIImage.init(named:"LaunchImage-800-667h@2x.png");
            }
            else if(Double.abs(Double.init(height) - 736.0) < Foundation.DBL_EPSILON) { // iPhone 6+
                self.backgroundView.image = UIImage.init(named:"LaunchImage-800-Portrait-736h@3x.png");
            }
            else { // iPhone 4S
                self.backgroundView.image = UIImage.init(named:"LaunchImage-700@2x.png");
            }
        }
        
        
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        initialY = self.view.frame.origin.y;
        initialSize = self.view.frame.size.height;
    }
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    @IBAction func resendEmailClicked()
    {
        APFPROJECTAPI.currentInstance().resendActivationWithEmail(nil);
    }
    
    
    @IBAction func loginButtonClicked()
    {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
}
