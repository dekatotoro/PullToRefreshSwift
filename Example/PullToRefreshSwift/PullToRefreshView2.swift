//
//  PullToRefreshView2.swift
//  PullToRefreshSwift
//
//  Created by 波戸 勇二 on 12/10/14.
//  Copyright (c) 2014 Yuji Hato. All rights reserved.
//

import UIKit

//let RefreshViewHeight:CFloat = 70.0
//let RefreshSlowAnimationDuration:NSTimeInterval = 0.3
let ContentOffsetKeyPath: NSString =  "contentOffset"
let ContentSizeKeyPath: NSString =  "contentSize"

enum RefreshState {
    case  Pulling
    case  Normal
    case  Refreshing
    case  WillRefreshing
}


let RefreshLabelTextColor:UIColor = UIColor(red: 150.0/255, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1)



class PullToRefreshView3: UIView {
    
    var scrollView:UIScrollView!
    var scrollViewOriginalInset:UIEdgeInsets!
    var statusLabel:UILabel!
    var arrowImage:UIImageView!
    var activityView:UIActivityIndicatorView!
    var beginRefreshingCallback:(()->Void)?
    var oldState:RefreshState?
    var State:RefreshState = RefreshState.Normal {
        
        willSet {
            if  State == newValue{
                return;
            }
            oldState = State
            setState(newValue)
        }
        
        didSet{
            switch State{
            case .Normal:
                self.statusLabel.text = PullToRefreshConst.pullText
                if RefreshState.Refreshing == oldState {
                    self.arrowImage.transform = CGAffineTransformIdentity
                    UIView.animateWithDuration(PullToRefreshConst.duration, animations: {
                        var contentInset:UIEdgeInsets = self.scrollView.contentInset
                        contentInset.top = self.scrollViewOriginalInset.top
                        self.scrollView.contentInset = contentInset
                    })
                    
                }else {
                    UIView.animateWithDuration(PullToRefreshConst.duration, animations: {
                        self.arrowImage.transform = CGAffineTransformIdentity
                    })
                }
                break
            case .Pulling:
                self.statusLabel.text = PullToRefreshConst.releaseText
                UIView.animateWithDuration(PullToRefreshConst.duration, animations: {
                    self.arrowImage.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                })
                break
            case .Refreshing:
                self.statusLabel.text =  PullToRefreshConst.loadingText;
                
                UIView.animateWithDuration(PullToRefreshConst.duration, animations: {
                    var top:CGFloat = self.scrollViewOriginalInset.top + self.frame.size.height
                    var inset:UIEdgeInsets = self.scrollView.contentInset
                    inset.top = top
                    self.scrollView.contentInset = inset
                    var offset:CGPoint = self.scrollView.contentOffset
                    offset.y = -top
                    self.scrollView.contentOffset = offset
                })
                break
            default:
                break
                
            }
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        statusLabel = UILabel()
        statusLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        statusLabel.font = UIFont.boldSystemFontOfSize(13)
        statusLabel.textColor = RefreshLabelTextColor
        statusLabel.backgroundColor =  UIColor.clearColor()
        statusLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(statusLabel)
        
        arrowImage = UIImageView(image: UIImage(named: "arrow.png"))
        arrowImage.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin |  UIViewAutoresizing.FlexibleRightMargin
        self.addSubview(arrowImage)
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.bounds = self.arrowImage.bounds
        activityView.autoresizingMask = self.arrowImage.autoresizingMask
        self.addSubview(activityView)
        
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.backgroundColor = UIColor.clearColor()
        
        self.State = RefreshState.Normal;
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let arrowX:CGFloat = self.frame.size.width * 0.5 - 100
        self.arrowImage.center = CGPointMake(arrowX, self.frame.size.height * 0.5)
        self.activityView.center = self.arrowImage.center
        var statusX:CGFloat = 0
        var statusY:CGFloat = 0
        var statusHeight:CGFloat = self.frame.size.height * 0.5
        var statusWidth:CGFloat = self.frame.size.width
        self.statusLabel.frame = CGRectMake(statusX, statusY, statusWidth, statusHeight)
    }
    
    
    override func willMoveToSuperview(newSuperview: UIView!) {
        super.willMoveToSuperview(newSuperview)
        
        
        if (self.superview != nil) {
            self.superview?.removeObserver(self, forKeyPath: ContentSizeKeyPath, context: nil)
            
        }
        
        if (newSuperview != nil) {
            newSuperview.addObserver(self, forKeyPath: ContentOffsetKeyPath, options: NSKeyValueObservingOptions.New, context: nil)
            var rect:CGRect = self.frame
            
            rect.size.width = newSuperview.frame.size.width
            rect.origin.x = 0
            self.frame = frame;
            
            scrollView = newSuperview as UIScrollView
            scrollViewOriginalInset = scrollView.contentInset;
        }
        
        var rect:CGRect = self.frame
        rect.origin.y = -self.frame.size.height
        self.frame = rect
    }
    
    
    override func drawRect(rect: CGRect) {
        superview?.drawRect(rect);
        if self.State == RefreshState.WillRefreshing {
            self.State = RefreshState.Refreshing
        }
    }
    
    func setState(newValue:RefreshState){
        if self.State != RefreshState.Refreshing {
            
            scrollViewOriginalInset = self.scrollView.contentInset;
        }
        if self.State == newValue {
            return
        }
        switch newValue {
        case .Normal:
            self.arrowImage.hidden = false
            self.activityView.stopAnimating()
            break
        case .Pulling:
            break
        case .Refreshing:
            self.arrowImage.hidden = true
            activityView.startAnimating()
            beginRefreshingCallback!()
            break
        default:
            break
            
        }
    }
    
    func isRefreshing()->Bool{
        return RefreshState.Refreshing == self.State;
    }
    
    func beginRefreshing(){
        // self.State = RefreshState.Refreshing;
        
        
        if (self.window != nil) {
            self.State = RefreshState.Refreshing;
        } else {
            //不能调用set方法
            State = RefreshState.WillRefreshing;
            super.setNeedsDisplay()
        }
        
    }
    
    func endRefreshing(){
        let delayInSeconds:Double = 0.3
        var popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds));
        
        dispatch_after(popTime, dispatch_get_main_queue(), {
            self.State = RefreshState.Normal;
        })
    }

   
    
    //MARK: KVO methods
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<()>) {

        if (!self.userInteractionEnabled || self.hidden){
            return
        }
        if (self.State == RefreshState.Refreshing) {
            return
        }
        if ContentOffsetKeyPath.isEqualToString(keyPath){
            self.adjustStateWithContentOffset()
        }
    }
    
    
    func adjustStateWithContentOffset()
    {
        var currentOffsetY:CGFloat = self.scrollView.contentOffset.y
        var happenOffsetY:CGFloat = -self.scrollViewOriginalInset.top
        if (currentOffsetY >= happenOffsetY) {
            return
        }
        if self.scrollView.dragging{
            var normal2pullingOffsetY:CGFloat = happenOffsetY - self.frame.size.height
            if  self.State == RefreshState.Normal && currentOffsetY < normal2pullingOffsetY{
                self.State = RefreshState.Pulling
            }else if self.State == RefreshState.Pulling && currentOffsetY >= normal2pullingOffsetY{
                self.State = RefreshState.Normal
            }
            
        } else if self.State == RefreshState.Pulling {
            self.State = RefreshState.Refreshing
        }
    }
    

    
    func addState(state:RefreshState){
        self.State = state
    }
}