//
//  APFRegisterViewController.swift
//  PROJECT
//
//  Created by Amir on 9/27/15.
//  Copyright © 2015 PROJECT. All rights reserved.
//

import UIKit

@objc class APFRegisterViewController : UIViewController,TTTAttributedLabelDelegate {
    
    @IBOutlet weak var backgroundView : UIImageView!;
    @IBOutlet weak var registerView : UIView!;
    
    @IBOutlet weak var logoView : UIImageView!;
    
    @IBOutlet weak var registerButton : UIButton!;
    @IBOutlet weak var loginButton : UIButton!;
    @IBOutlet weak var tosLabel : TTTAttributedLabel!;

    
    @IBOutlet weak var iconLeftMargin : NSLayoutConstraint!;
    @IBOutlet weak var iconRightMargin : NSLayoutConstraint!;
    
    @IBOutlet weak var backgroundBottomConstraint : NSLayoutConstraint!;
    @IBOutlet weak var registerBottomConstraint : NSLayoutConstraint!;
    
    @IBOutlet weak var scrollHeight : NSLayoutConstraint!;
    @IBOutlet weak var scrollWidth : NSLayoutConstraint!;
    
    @IBOutlet weak var nameTextField : UITextField!;
    @IBOutlet weak var telTextField : UITextField!;
    @IBOutlet weak var emailTextField : UITextField!;
    @IBOutlet weak var passwordTextField : UITextField!;
    
    @IBOutlet weak var nameLabel : UILabel!;
    @IBOutlet weak var telLabel : UILabel!;
    @IBOutlet weak var emailLabel : UILabel!;
    @IBOutlet weak var passwordLabel : UILabel!;
    
    
    var activeTextField : UITextField!;
    
    var isTopActive : Bool!;
    
    var parent : UIViewController!
    
    
    var initialY : CGFloat!;
    var initialSize : CGFloat!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        let height : CGFloat = UIScreen.mainScreen().bounds.size.height;
        
        if(Double.abs(Double.init(height) - 480.0) < Foundation.DBL_EPSILON) { // iPhone 4s
            self.logoView.image = UIImage(named:"APFIconRegister4s.png");
            iconLeftMargin.constant = 96;
            iconRightMargin.constant = 96;
        }
        
        self.registerButton.layer.cornerRadius = 4.0;
        self.loginButton.layer.borderColor = UIColor.whiteColor().CGColor;
        self.loginButton.layer.borderWidth = 1.5;
        self.loginButton.layer.cornerRadius = 4.0;
        
        
        let tap : UITapGestureRecognizer! = UITapGestureRecognizer.init(target: self, action: "dismissKeyboard");
        self.view.addGestureRecognizer(tap);
        
        
        
        let str : NSMutableAttributedString = NSMutableAttributedString.init(string: tosLabel.text!);
        tosLabel.delegate = self
        tosLabel.userInteractionEnabled = true
        tosLabel.linkAttributes = [kCTForegroundColorAttributeName : tosLabel.textColor,kCTUnderlineStyleAttributeName : NSUnderlineStyle.StyleNone.rawValue,NSFontAttributeName : UIFont.init(name: "IRANSans-Bold", size: 11)!]
        
        let text_attrs = [NSFontAttributeName : UIFont.init(name: "IRANSans", size: 10)!,NSForegroundColorAttributeName : tosLabel.textColor,NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleNone.rawValue];
        
        str.addAttributes(text_attrs, range: NSMakeRange(0, tosLabel.text!.characters.count));
        tosLabel.setText(str);
        
        tosLabel.addLinkToURL(NSURL.init(string: "https://PROJECT.ir/tos"), withRange: NSMakeRange(24, 15));
        
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
        if (activeTextField != nil)
        {
            activeTextField.resignFirstResponder();
        }
    }
    
    
    @IBAction func textFieldDidBeginEditing(textField:UITextField)
    {
        activeTextField = textField;
        if textField == emailTextField || textField == nameTextField
        {
            isTopActive = true;
        }
        else
        {
            isTopActive = false;
        }
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
        self.registerBottomConstraint.constant = (UIDevice.currentDevice().userInterfaceIdiom == .Phone) ? 25.0 : 50.0;
        
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
    
        
        if isTopActive != nil && isTopActive == true
        {
            self.view.frame.origin.y = initialY;
            self.view.frame.size.height = initialSize;
            self.backgroundBottomConstraint.constant = 0.0;
            self.registerBottomConstraint.constant = 0.0 + ((UIDevice.currentDevice().userInterfaceIdiom == .Phone) ? 25.0 : 50.0);
        }
        else
        {
            let kHeight = kbdHeight - 6;
            self.view.frame.origin.y = initialY - kHeight
            self.view.frame.size.height = initialSize + kHeight;
            self.backgroundBottomConstraint.constant = kHeight;
            self.registerBottomConstraint.constant = kHeight + ((UIDevice.currentDevice()
                .userInterfaceIdiom == .Phone) ? 25.0 : 25.0);
        }
//        self.updateViewConstraints();
//        self.backgroundView.layoutIfNeeded();
//        self.registerView.layoutIfNeeded();
        
        UIView.commitAnimations();
    }
    
    @IBAction func didTextChanged(textField:UITextField)
    {
        var map : [UITextField:UILabel] = [
            nameTextField:nameLabel,
            telTextField:telLabel,
            emailTextField:emailLabel,
            passwordTextField:passwordLabel
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
    
    @IBAction func registerButtonClicked()
    {
        dismissKeyboard();
        APFPROJECTAPI.currentInstance().registerWithEmail(emailTextField.text, password: passwordTextField.text, name: nameTextField.text, tel: telTextField.text);
    }

    
    @IBAction func loginButtonClicked()
    {
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentedViewController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
}
