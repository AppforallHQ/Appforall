//
//  APFRegisterViewController.swift
//  PROJECT
//
//  Created by Amir on 9/27/15.
//  Copyright © 2015 PROJECT. All rights reserved.
//

import UIKit

@objc class APFEmailActivationController : UIViewController{
    
    @IBOutlet weak var backgroundView : UIImageView!;
    @IBOutlet weak var loginView : UIView!;
    
    
    @IBOutlet weak var sendEmailButton : UIButton!;
    @IBOutlet weak var loginButton : UIButton!;
    
    @IBOutlet weak var bottomConstraint : NSLayoutConstraint!;
    @IBOutlet weak var imgWidth: NSLayoutConstraint!;
    
    var parent : UIViewController!
    
    
    var initialY : CGFloat!;
    var initialSize : CGFloat!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let height : CGFloat = UIScreen.mainScreen().bounds.size.height;
        self.sendEmailButton.layer.cornerRadius = 4.0;
        imgWidth.constant = height*4/3;
        
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
        APFPROJECTAPI.currentInstance().hideEmailActivation()
    }
    
    
}
