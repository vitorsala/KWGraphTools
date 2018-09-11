//
//  vector_int2+Utils.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 02/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import GameplayKit

extension vector_int2 {
    init(point: GridPoint) {
        self.init(Int32(point.x), Int32(point.y))
    }
}
