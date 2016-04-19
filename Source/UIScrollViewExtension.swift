//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import Foundation
import UIKit

public extension UIScrollView {
    
    private func refreshViewWithTag(tag:Int) -> PullToRefreshView? {
        let pullToRefreshView = viewWithTag(tag)
        return pullToRefreshView as? PullToRefreshView
    }

    public func addPullRefreshHandler(refreshCompletion :(Void -> Void)?) {
        self.addPullRefresh(refreshCompletion)
    }
    
    public func addPushRefreshHandler(refreshCompletion :(Void -> Void)?) {
        self.addPushRefresh(refreshCompletion)
    }
    
    private func addPullRefresh(refreshCompletion :((Void -> Void)?), options: PullToRefreshOption = PullToRefreshOption()) {
        let refreshViewFrame = CGRectMake(0, -PullToRefreshConst.height, self.frame.size.width, PullToRefreshConst.height)
        let refreshView = PullToRefreshView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion)
        refreshView.tag = PullToRefreshConst.pullTag
        addSubview(refreshView)
    }
    
    private func addPushRefresh(refreshCompletion :((Void -> Void)?), options: PullToRefreshOption = PullToRefreshOption()) {
        let refreshViewFrame = CGRectMake(0, contentSize.height, self.frame.size.width, PullToRefreshConst.height)
        let refreshView = PullToRefreshView(options: options, frame: refreshViewFrame, refreshCompletion: refreshCompletion,down: false)
        refreshView.tag = PullToRefreshConst.pushTag
        addSubview(refreshView)
    }
    
    public func startPullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.state = .Refreshing
    }
    
    public func stopPullRefreshEver(ever:Bool = false) {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if ever {
            refreshView?.state = .Finish
        } else {
            refreshView?.state = .Stop
        }
    }
    
    public func removePullRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        refreshView?.removeFromSuperview()
    }
    
    public func startPushRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        refreshView?.state = .Refreshing
    }
    
    public func stopPushRefreshEver(ever:Bool = false) {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        if ever {
            refreshView?.state = .Finish
        } else {
            refreshView?.state = .Stop
        }
    }
    
    public func removePushRefresh() {
        let refreshView = self.refreshViewWithTag(PullToRefreshConst.pushTag)
        refreshView?.removeFromSuperview()
    }
    
    // If you want to PullToRefreshView fixed top potision, Please call this function in scrollViewDidScroll
    public func fixedPullToRefreshViewForDidScroll() {
        let pullToRefreshView = self.refreshViewWithTag(PullToRefreshConst.pullTag)
        if !PullToRefreshConst.fixedTop || pullToRefreshView == nil {
            return
        }
        var frame = pullToRefreshView!.frame
        if self.contentOffset.y < -PullToRefreshConst.height {
            frame.origin.y = self.contentOffset.y
            pullToRefreshView!.frame = frame
        }
        else {
            frame.origin.y = -PullToRefreshConst.height
            pullToRefreshView!.frame = frame
        }
    }
}
