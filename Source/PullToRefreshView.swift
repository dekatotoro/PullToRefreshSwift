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
    
    private var options: PullToRefreshOption!
    private var backgroundView: UIView!
    private var arrow: UIImageView!
    private var indicator: UIActivityIndicatorView!
    private var scrollViewBounces: Bool = false
    private var scrollViewInsets: UIEdgeInsets = UIEdgeInsetsZero
    private var previousOffset: CGFloat = 0
    private var refreshCompletion: (() -> ()) = {}
    
    var state: PullToRefreshState = PullToRefreshState.Normal {
        didSet {
            if self.state == oldValue {
                return
            }
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
    
    convenience init(options: PullToRefreshOption, frame: CGRect, refreshCompletion :(() -> ())) {
        self.init(frame: frame)
        self.options = options
        self.refreshCompletion = refreshCompletion

        self.backgroundView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        self.backgroundView.backgroundColor = self.options.backgroundColor
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
        self.indicator.color = options.indicatorColor
        self.addSubview(indicator)
        
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
    }
   
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.arrow.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        self.indicator.center = self.arrow.center
    }
    
    public override func willMoveToSuperview(superView: UIView!) {
        
        superview?.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
        
        if let scrollView = superView as? UIScrollView {
            scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .Initial, context: &kvoContext)
        }
    }
    
    deinit {
        if let scrollView = superview as? UIScrollView {
            scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
        }
    }
    
    // MARK: KVO
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {
        
        if (context == &kvoContext && keyPath == contentOffsetKeyPath) {
            if let scrollView = object as? UIScrollView {
                
                // Debug
                //println(scrollView.contentOffset.y)
                
                var offsetWithoutInsets = self.previousOffset + self.scrollViewInsets.top
                
                // Update the content inset for fixed section headers
                if self.options.fixedSectionHeader && self.state == .Refreshing {
                    if (scrollView.contentOffset.y > 0) {
                        scrollView.contentInset = UIEdgeInsetsZero;
                    }
                    return
                }
                
                // Alpha set
                if PullToRefreshConst.alpha {
                    var alpha = fabs(offsetWithoutInsets) / (self.frame.size.height + 30)
                    if alpha > 0.8 {
                        alpha = 0.8
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
        
        if let scrollView = superview as? UIScrollView {
            scrollViewBounces = scrollView.bounces
            scrollViewInsets = scrollView.contentInset
            
            var insets = scrollView.contentInset
            insets.top += self.frame.size.height
            scrollView.contentOffset.y = self.previousOffset
            scrollView.bounces = false
            UIView.animateWithDuration(PullToRefreshConst.animationDuration, delay: 0, options:nil, animations: {
                scrollView.contentInset = insets
                scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -insets.top)
                }, completion: {finished in
                    if self.options.autoStopTime != 0 {
                        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(self.options.autoStopTime * Double(NSEC_PER_SEC)))
                        dispatch_after(time, dispatch_get_main_queue()) {
                            self.state = .Normal
                        }
                    }
                    self.refreshCompletion()
            })
        }
    }
    
    private func stopAnimating() {
        self.indicator.stopAnimating()
        self.arrow.transform = CGAffineTransformIdentity
        self.arrow.hidden = false
        
        if let scrollView = superview as? UIScrollView {
            scrollView.bounces = self.scrollViewBounces
            UIView.animateWithDuration(PullToRefreshConst.animationDuration, animations: { () -> Void in
                scrollView.contentInset = self.scrollViewInsets
                }) { (Bool) -> Void in
                    
            }
        }
    }
    
    private func arrowRotation() {
        UIView.animateWithDuration(0.2, delay: 0, options:nil, animations: {
            // -0.0000001 for the rotation direction control
            self.arrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI-0.0000001))
        }, completion:nil)
    }
    
    private func arrowRotationBack() {
        UIView.animateWithDuration(0.2, delay: 0, options:nil, animations: {
            self.arrow.transform = CGAffineTransformIdentity
            }, completion:nil)
    }
}
