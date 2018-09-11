//
//  SKReferenceNode.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 01/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

extension SKReferenceNode {
    func baseChildrens() -> SKNode? {
        return self.children.first
    }
}
