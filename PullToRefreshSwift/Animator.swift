//
//  Animator.swift
//  AmebaBlog
//
//  Created by 波戸 勇二 on 11/21/14.
//
//
import Foundation
import QuartzCore
import UIKit

class Animator: PullToRefreshViewAnimator {
    
    private var layerLoader: CAShapeLayer = CAShapeLayer()
    
    init() {
        layerLoader.lineWidth = 3
        layerLoader.strokeColor = UIColor.greenColor().CGColor
        layerLoader.strokeEnd = 0
    }
    
    func startAnimation() {
     
    }
    
    func stopAnimation() {
        self.layerLoader.removeAllAnimations()
    }
    
    func layoutLayers(superview: UIView) {
        if layerLoader.superlayer == nil {
            superview.layer .addSublayer(layerLoader)
        }
        var bezierPathLoader = UIBezierPath()
        bezierPathLoader.moveToPoint(CGPointMake(0, superview.frame.height - 3))
        bezierPathLoader.addLineToPoint(CGPoint(x: superview.frame.width, y: superview.frame.height - 3))
        
        var bezierPathSeparator = UIBezierPath()
        bezierPathSeparator.moveToPoint(CGPointMake(0, superview.frame.height - 1))
        bezierPathSeparator.addLineToPoint(CGPoint(x: superview.frame.width, y: superview.frame.height - 1))
        
        layerLoader.path = bezierPathLoader.CGPath
    }
    
    func changeProgress(progress: CGFloat) {
        self.layerLoader.strokeEnd = progress
    }
}