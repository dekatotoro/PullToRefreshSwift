PullToRefreshSwift
==================

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)
[![Issues](https://img.shields.io/github/issues/dekatotoro/PullToRefreshSwift.svg?style=flat
)](https://github.com/dekatotoro/PullToRefreshSwift/issues?state=open)



iOS Simple PullToRefresh Library.

![sample](Screenshots/PullToRefreshSwift.gif)

##Installation

####CocoaPods
comming soon...

####Manually
Add the following files to your project. 
`pulltorefresharrow.png`
`PullToRefreshView.swift`
`PullToRefreshConst.swift`
`UIScrollViewExtension.swift`


##Usage

###Setup

In your UIViewController Including UITableView, UICollectionView, UIScrollView:
```swift
  override func viewDidLoad() {
        self.tableView.addPullToRefresh({ () -> () in
            // refresh code
            
            self.tableView.reloadData()
            self.tableView.stopPullToRefresh()
        })
  }
```
  
If you want to fixed pulltoRefreshView, please implement scrollViewDidScroll.
```swift
  func scrollViewDidScroll(scrollView: UIScrollView) {
    self.tableView.fixedPullToRefreshViewForDidScroll()
  }  
```
  
If you want to use the custom option, please change the PullToRefreshConst class.

```swift
struct PullToRefreshConst {
    static let backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
    static let imageName: String = "pulltorefresharrow.png"
    static let height: CGFloat = 80
    static let duration: Double = 0.5
    static let tag = 810
    static let alpha = true
}
```

## Requirements
Requires iOS 7.0 and ARC.

## Features
- Highly customizable
- Complete example
- Refactoring

## Contributing

Forks, patches and other feedback are welcome.

## Creator

[Yuji Hato](https://github.com/dekatotoro) 
[Blog](http://buzzmemo.blogspot.jp/)

## License

PullToRefreshSwift is available under the MIT license. See the LICENSE file for more info.
