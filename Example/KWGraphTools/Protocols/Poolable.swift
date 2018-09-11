//
//  Poolable.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 05/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

protocol Poolable: Hashable {
    static func generateNewNode() -> Self
}
