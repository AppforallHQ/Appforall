//
//  APFWelcomeLogo.swift
//
//  Code generated using QuartzCode 1.21 on 14/1/94.
//  www.quartzcodeapp.com
//

import UIKit

@objc class APFWelcomeLogo: UIView {
    var path : CAShapeLayer!
    var path2 : CAShapeLayer!
    var path3 : CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayers()
    }
    
    func setupLayers() {
        self.backgroundColor = UIColor(red:1, green: 1, blue:1, alpha:0)
        
        let Group = CALayer()
        Group.frame = CGRectMake(-0, 0.33, 125, 125)
        
        self.layer.addSublayer(Group)
        
        path = CAShapeLayer()
        path.frame     = CGRectMake(29.78, 32.23, 38.82, 60.55)
        path.opacity   = 0
        path.fillColor = UIColor.blackColor().CGColor
        path.lineWidth = 0
        path.path      = pathPath().CGPath;
        Group.addSublayer(path)
        
        path2 = CAShapeLayer()
        path2.frame     = CGRectMake(66.16, 40.58, 29.05, 52.19)
        path2.opacity   = 0
        path2.fillColor = UIColor.blackColor().CGColor
        path2.lineWidth = 0
        path2.path      = path2Path().CGPath;
        Group.addSublayer(path2)
        
        path3 = CAShapeLayer()
        path3.frame     = CGRectMake(0, 0, 125, 125)
        path3.opacity   = 0
        path3.fillColor = UIColor.blackColor().CGColor
        path3.lineWidth = 0
        path3.path      = path3Path().CGPath;
        Group.addSublayer(path3)
    }
    
    
    @IBAction func startAllAnimations(sender: AnyObject!){
        
        path?.addAnimation(pathAnimation(), forKey:"pathAnimation")
        path2?.addAnimation(path2Animation(), forKey:"path2Animation")
        path3?.addAnimation(path3Animation(), forKey:"path3Animation")
    }
    
    func pathAnimation() -> CAAnimationGroup{
        let opacityAnim            = CABasicAnimation(keyPath:"opacity")
        opacityAnim.fromValue      = 0;
        opacityAnim.toValue        = 1;
        opacityAnim.duration       = 1.5
        opacityAnim.beginTime      = 0.5
        opacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
        let pathAnimGroup                 = CAAnimationGroup()
        opacityAnim.setValue(kCAFillModeForwards, forKeyPath: "fillMode")
        pathAnimGroup.animations          = [opacityAnim]
        pathAnimGroup.fillMode            = kCAFillModeForwards
        pathAnimGroup.removedOnCompletion = false
        pathAnimGroup.duration = QCMethod.maxDurationFromAnimations(pathAnimGroup.animations!)
        
        
        return pathAnimGroup;
    }
    
    func path2Animation() -> CAAnimationGroup{
        let opacityAnim            = CABasicAnimation(keyPath:"opacity")
        opacityAnim.fromValue      = 0;
        opacityAnim.toValue        = 1;
        opacityAnim.duration       = 1.5
        opacityAnim.beginTime      = 0.25
        opacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        
        let path2AnimGroup                 = CAAnimationGroup()
        opacityAnim.setValue(kCAFillModeForwards, forKeyPath:"fillMode")
        path2AnimGroup.animations          = [opacityAnim]
        path2AnimGroup.fillMode            = kCAFillModeForwards
        path2AnimGroup.removedOnCompletion = false
        path2AnimGroup.duration = QCMethod.maxDurationFromAnimations(path2AnimGroup.animations!)
        
        
        return path2AnimGroup;
    }
    
    func path3Animation() -> CABasicAnimation{
        let opacityAnim            = CABasicAnimation(keyPath:"opacity")
        opacityAnim.fromValue      = 0;
        opacityAnim.toValue        = 1;
        opacityAnim.duration       = 2
        opacityAnim.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseIn)
        opacityAnim.fillMode = kCAFillModeForwards
        opacityAnim.removedOnCompletion = false
        
        return opacityAnim;
    }
    
    //MARK: - Bezier Path
    
    func pathPath() -> UIBezierPath{
        let pathPath = UIBezierPath()
        pathPath.moveToPoint(CGPointMake(0, 60.547))
        pathPath.addLineToPoint(CGPointMake(26.642, 0))
        pathPath.addLineToPoint(CGPointMake(38.82, 0))
        pathPath.addLineToPoint(CGPointMake(12.178, 60.547))
        pathPath.closePath()
        pathPath.moveToPoint(CGPointMake(0, 60.547))
        
        return pathPath;
    }
    
    func path2Path() -> UIBezierPath{
        let path2Path = UIBezierPath()
        path2Path.moveToPoint(CGPointMake(0, 13.838))
        path2Path.addLineToPoint(CGPointMake(6.089, 0))
        path2Path.addLineToPoint(CGPointMake(29.053, 52.19))
        path2Path.addLineToPoint(CGPointMake(16.875, 52.19))
        path2Path.closePath()
        path2Path.moveToPoint(CGPointMake(0, 13.838))
        
        return path2Path;
    }
    
    func path3Path() -> UIBezierPath{
        let path3Path = UIBezierPath()
        path3Path.moveToPoint(CGPointMake(95.703, 0))
        path3Path.addLineToPoint(CGPointMake(29.297, 0))
        path3Path.addCurveToPoint(CGPointMake(0, 29.297), controlPoint1:CGPointMake(13.117, 0), controlPoint2:CGPointMake(0, 13.117))
        path3Path.addLineToPoint(CGPointMake(0, 95.703))
        path3Path.addCurveToPoint(CGPointMake(29.297, 125), controlPoint1:CGPointMake(0, 111.883), controlPoint2:CGPointMake(13.117, 125))
        path3Path.addLineToPoint(CGPointMake(95.703, 125))
        path3Path.addCurveToPoint(CGPointMake(125, 95.703), controlPoint1:CGPointMake(111.883, 125), controlPoint2:CGPointMake(125, 111.883))
        path3Path.addLineToPoint(CGPointMake(125, 29.297))
        path3Path.addCurveToPoint(CGPointMake(95.703, 0), controlPoint1:CGPointMake(125, 13.117), controlPoint2:CGPointMake(111.883, 0))
        path3Path.closePath()
        path3Path.moveToPoint(CGPointMake(117.188, 95.703))
        path3Path.addCurveToPoint(CGPointMake(95.703, 117.188), controlPoint1:CGPointMake(117.188, 107.569), controlPoint2:CGPointMake(107.569, 117.188))
        path3Path.addLineToPoint(CGPointMake(29.297, 117.188))
        path3Path.addCurveToPoint(CGPointMake(7.812, 95.703), controlPoint1:CGPointMake(17.431, 117.188), controlPoint2:CGPointMake(7.812, 107.569))
        path3Path.addLineToPoint(CGPointMake(7.812, 29.297))
        path3Path.addCurveToPoint(CGPointMake(29.297, 7.812), controlPoint1:CGPointMake(7.812, 17.431), controlPoint2:CGPointMake(17.431, 7.812))
        path3Path.addLineToPoint(CGPointMake(95.703, 7.812))
        path3Path.addCurveToPoint(CGPointMake(117.188, 29.297), controlPoint1:CGPointMake(107.569, 7.812), controlPoint2:CGPointMake(117.188, 17.431))
        path3Path.addLineToPoint(CGPointMake(117.188, 95.703))
        path3Path.closePath()
        path3Path.moveToPoint(CGPointMake(117.188, 95.703))
        
        return path3Path;
    }
    
}