//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import UIKit

public class PullToRefreshView: UIView {
    enum PullToRefreshState {
        case Normal
        case Pulling
        case Refreshing
    }
    
    // MARK: Variables
    let contentOffsetKeyPath = "contentOffset"
    var kvoContext = ""
    
    private var backgroundView: UIView!
    private var arrow: UIImageView!
    private var indicator: UIActivityIndicatorView!
    private var scrollViewBounces: Bool = false
    private var scrollViewInsets: UIEdgeInsets = UIEdgeInsetsZero
    private var previousOffset: CGFloat = 0
    private var refreshCompletion: (() -> ()) = {}
    
    var state: PullToRefreshState = PullToRefreshState.Normal {
        didSet {
            switch self.state {
            case .Normal:
                stopAnimating()
            case .Refreshing:
                startAnimating()
            default:
                break
            }
        }
    }
    
    // MARK: UIView
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(refreshCompletion :(() -> ()), frame: CGRect) {
        self.init(frame: frame)
        self.refreshCompletion = refreshCompletion;

        self.backgroundView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        self.backgroundView.backgroundColor = PullToRefreshConst.backgroundColor
        self.backgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.addSubview(backgroundView)
        
        self.arrow = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        self.arrow.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |  UIViewAutoresizing.FlexibleRightMargin
        self.arrow.image = UIImage(named: PullToRefreshConst.imageName)
        self.addSubview(arrow)
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.indicator.bounds = self.arrow.bounds
        self.indicator.autoresizingMask = self.arrow.autoresizingMask
        self.indicator.hidesWhenStopped = true
        self.addSubview(indicator)
        
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
//        self.backgroundColor = PullToRefreshConst.backgroundColor
    }
   
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.arrow.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        self.indicator.center = self.arrow.center
    }
    
    public override func willMoveToSuperview(superView: UIView!) {
        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
        if (superView != nil && superView is UIScrollView) {
            superView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &kvoContext)
            scrollViewBounces = (superView as UIScrollView).bounces
            scrollViewInsets = (superView as UIScrollView).contentInset
            
            println((superView as UIScrollView).contentOffset.y)
            println((superView as UIScrollView).contentInset.top)
        }
    }
    
    deinit {
        var scrollView = superview as? UIScrollView
        scrollView?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
    }
    
    // MARK: KVO
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        
        if (context == &kvoContext && keyPath == contentOffsetKeyPath) {
            if let scrollView = object as? UIScrollView {
                
                // Debug
                //println(scrollView.contentOffset.y)
                
                var offsetWithoutInsets = self.previousOffset + self.scrollViewInsets.top
                
                // Alpha set
                if PullToRefreshConst.alpha {
                    var alpha = fabs(offsetWithoutInsets) / (self.frame.size.height + 30)
                    if alpha > 0.9 {
                        alpha = 0.9
                    }
                    self.arrow.alpha = alpha
                }
                
                // Backgroundview frame set
                if PullToRefreshConst.fixedTop {
                    if PullToRefreshConst.height < fabs(offsetWithoutInsets) {
                        self.backgroundView.frame.size.height = fabs(offsetWithoutInsets)
                    } else {
                        self.backgroundView.frame.size.height =  PullToRefreshConst.height
                    }
                } else {
                    self.backgroundView.frame.size.height = PullToRefreshConst.height + fabs(offsetWithoutInsets)
                    self.backgroundView.frame.origin.y = -fabs(offsetWithoutInsets)
                }
                
                // Pulling State Check
                if (offsetWithoutInsets < -self.frame.size.height) {
                    
                    // pulling or refreshing
                    if (scrollView.dragging == false && self.state != .Refreshing) {
                        self.state = .Refreshing
                    } else if (self.state != .Refreshing) {
                        self.arrowRotation()
                        self.state = .Pulling
                    }
                } else if (self.state != .Refreshing && offsetWithoutInsets < 0) {
                    // normal
                    self.arrowRotationBack()
                    self.state == .Normal
                }
                self.previousOffset = scrollView.contentOffset.y
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: private
    
    private func startAnimating() {
        self.indicator.startAnimating()
        self.arrow.hidden = true
        
        var scrollView = superview as UIScrollView
        var insets = scrollView.contentInset
        insets.top += self.frame.size.height
        scrollView.contentOffset.y = self.previousOffset
        scrollView.bounces = false
        UIView.animateWithDuration(PullToRefreshConst.duration, delay: 0, options:nil, animations: {
            scrollView.contentInset = insets
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets.top)
        }, completion: {finished in
                self.state = .Normal
                self.refreshCompletion()
        })
    }
    
    private func stopAnimating() {
        self.indicator.stopAnimating()
        self.arrow.transform = CGAffineTransformIdentity
        self.arrow.hidden = false
        
        var scrollView = superview as UIScrollView
        scrollView.bounces = self.scrollViewBounces
        UIView.animateWithDuration(PullToRefreshConst.duration, animations: { () -> Void in
            scrollView.contentInset = self.scrollViewInsets
        }) { (Bool) -> Void in

        }
    }
    
    private func arrowRotation() {
        UIView.animateWithDuration(0.2, delay: 0, options:nil, animations: {
            // -0.0000001 for the rotation direction control
            self.arrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI-0.0000001))
            }, nil)
    }
    
    private func arrowRotationBack() {
        UIView.animateWithDuration(0.2, delay: 0, options:nil, animations: {
            self.arrow.transform = CGAffineTransformIdentity
            }, nil)
    }
}
