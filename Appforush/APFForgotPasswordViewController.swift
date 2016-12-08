//
//  APFRegisterViewController.swift
//  PROJECT
//
//  Created by Amir on 9/27/15.
//  Copyright © 2015 PROJECT. All rights reserved.
//

import UIKit

@objc class APFForgotPasswordViewController : UIViewController {
    
    @IBOutlet weak var backgroundView : UIImageView!;
    @IBOutlet weak var registerView : UIView!;
    
    @IBOutlet weak var sendEmailButton : UIButton!;
    @IBOutlet weak var loginButton : UIButton!;
    
    
    @IBOutlet weak var backgroundBottomConstraint : NSLayoutConstraint!;
    @IBOutlet weak var registerBottomConstraint : NSLayoutConstraint!;
    
    
    @IBOutlet weak var emailTextField : UITextField!;

    
    @IBOutlet weak var emailLabel : UILabel!;
    
    
    var parent : UIViewController!
    
    
    var initialY : CGFloat!;
    var initialSize : CGFloat!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let height : CGFloat = UIScreen.mainScreen().bounds.size.height;
        

        
        self.sendEmailButton.layer.cornerRadius = 4.0;
        
        
        let tap : UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard");
        self.view.addGestureRecognizer(tap);
        
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
        
        
        /*
        self.usernameTextField.tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        self.passwordTextField.tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        
        self.usernameHRuleHeightConstraint.constant = 1 / [UIScreen mainScreen].scale;
        self.passwordHRuleHeightConstraint.constant = 1 / [UIScreen mainScreen].scale;
        */
        
        
        
    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        UIApplication.sharedApplication().openURL(url);
    }
    
    
    func dismissKeyboard()
    {
        emailTextField.resignFirstResponder();
    }
    

    
    
    func registerForKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasHid:", name: UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillChangeFrameNotification, object: nil);
    }
    
    
    func unregisterForKeyboardNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil);
    }
    
    func keyboardWasHid(aNotification:NSNotification)
    {
        let info : NSDictionary! = aNotification.userInfo!;
        
        UIView.beginAnimations(nil, context: nil);
        UIView.setAnimationDuration((info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue)!);
        UIView.setAnimationCurve(UIViewAnimationCurve.init(rawValue:(info[UIKeyboardAnimationCurveUserInfoKey]?.integerValue)!)!);
        
        
        UIView.setAnimationBeginsFromCurrentState(true);
        
        self.view.frame.origin.y = initialY;
        self.view.frame.size.height = initialSize;
        self.backgroundBottomConstraint.constant = 0.0;
        self.registerBottomConstraint.constant = (UIDevice.currentDevice().userInterfaceIdiom == .Phone) ? 25.0 : 100.0;
        
        self.backgroundView.layoutIfNeeded();
        self.registerView.layoutIfNeeded();
        
        UIView.commitAnimations();
        
    }
    
    func keyboardWasShown(aNotification:NSNotification) {
        //NSLog("KEYBOARD EVENT");
        let info : NSDictionary! = aNotification.userInfo!;
        let kbdHeight : CGFloat = (info.objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue.size.height)!;
        let deviceHeight : CGFloat = UIScreen.mainScreen().bounds.size.height;
        
        
        UIView.beginAnimations(nil, context: nil);
        UIView.setAnimationDuration((info[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue)!);
        UIView.setAnimationCurve(UIViewAnimationCurve.init(rawValue:(info[UIKeyboardAnimationCurveUserInfoKey]?.integerValue)!)!);
        UIView.setAnimationBeginsFromCurrentState(true);
        
        

        let kHeight = kbdHeight - 6;
        self.view.frame.origin.y = initialY - kHeight
        self.view.frame.size.height = initialSize + kHeight;
        self.backgroundBottomConstraint.constant = kHeight;
        self.registerBottomConstraint.constant = kHeight + ((UIDevice.currentDevice()
            .userInterfaceIdiom == .Phone) ? 25.0 : 50.0);
        //        self.updateViewConstraints();
        //        self.backgroundView.layoutIfNeeded();
        //        self.registerView.layoutIfNeeded();
        
        UIView.commitAnimations();
    }
    
    @IBAction func didTextChanged(textField:UITextField)
    {
        var map : [UITextField:UILabel] = [
            emailTextField:emailLabel,
        ];
        if textField.text?.characters.count > 0 {
            map[textField]!.hidden = true;
        }
        else{
            map[textField]!.hidden = false;
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        registerForKeyboardNotifications();
        initialY = self.view.frame.origin.y;
        initialSize = self.view.frame.size.height;
    }
    
    override func viewDidDisappear(animated: Bool) {
        unregisterForKeyboardNotifications();
    }
    
    @IBAction func sendEmailButtonClicked()
    {
        dismissKeyboard();
        APFPROJECTAPI.currentInstance().forgotPasswordWithEmail(emailTextField.text);
    }
    
    
    @IBAction func loginButtonClicked()
    {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
}
