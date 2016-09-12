//
//  ArrayExtention.swift
//  PullToRefreshSwift
//
//  Created by 波戸 勇二 on 12/11/14.
//  Copyright (c) 2014 Yuji Hato. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func shuffle() {
        for _ in 0..<self.count {
            sort { (_,_) in arc4random() < arc4random() }
        }
    }
}
