//
//  GridPoint.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 28/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

struct GridPoint: Hashable {
    let x: Int
    let y: Int
    
    var cgPoint: CGPoint {
        return CGPoint(x: self.x, y: self.y)
    }
}
