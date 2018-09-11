//
//  SKNode+Utils.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 02/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

extension SKNode {
    func childNode(named: NodeName) -> SKNode? {
        return self.childNode(withName: named.name)
    }
}
