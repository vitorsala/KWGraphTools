//
//  PoolingSystem.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 05/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

final class PoolingSystem<T: Poolable> where T: SKNode{
    var pooledObject: Set<T> = Set()
    
    func push(node: T) {
        node.removeAllActions()
        node.removeFromParent()
        self.pooledObject.insert(node)
    }
    
    func pop() -> T {
        guard let node = self.pooledObject.popFirst() else {
            return T.generateNewNode()
        }
        return node
    }
}
