//
//  PullToRefreshConst.swift
//  PullToRefreshSwift
//
//  Created by Yuji Hato on 12/11/14.
//
import UIKit

struct PullToRefreshConst {
    static let pullTag = 810
    static let pushTag = 811
    static let alpha = true
    static let height: CGFloat = 80
    static let imageName: String = "pulltorefresharrow.png"
    static let animationDuration: Double = 0.5
    static let fixedTop = true // PullToRefreshView fixed Top
}

public struct PullToRefreshOption {
    public var backgroundColor = UIColor.clear
    public var indicatorColor = UIColor.gray
    public var autoStopTime: Double = 0 // 0 is not auto stop
    public var fixedSectionHeader = false  // Update the content inset for fixed section headers
}
