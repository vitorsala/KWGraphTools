//
//  WalkerNode.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 05/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit
import GameplayKit
import KWGraphTools

final class WalkerNode: SKShapeNode {
    var gridPoint: GridPoint = GridPoint(x: 0, y: 0)
    var gridPath: [vector_int2] = []
    
    func followPath(gridGraph: KWGridGraph, completion: @escaping (() -> Void)) {
        self.gridPath = gridGraph.findPath(from: vector_int2(point: self.gridPoint))
        _ = self.gridPath.removeFirst()
        guard !gridPath.isEmpty else {
            completion()
            return
        }
        self.animate(completion: completion)
    }
    
    private func animate(completion: @escaping (() -> Void)) {
        let actions = self.generateActions()
        self.run(SKAction.sequence(actions), completion: completion)
    }
    
    private func generateActions() -> [SKAction] {
        guard let tileMap = self.parent as? SKTileMapNode else { return [] }
        let actions = self.gridPath.map { (node) -> SKAction in
            let destinationPoint = tileMap.centerOfTile(atColumn: Int(node.x), row: Int(node.y))
            let action = SKAction.move(to: destinationPoint, duration: 0.5)
            return action
        }
        return actions
    }
}

extension WalkerNode: Poolable {
    static func generateNewNode() -> WalkerNode {
        let node = WalkerNode(circleOfRadius: 20)
        node.strokeColor = .black
        node.fillColor = .yellow
        node.lineWidth = 2
        node.zPosition = 10
        return node
    }
}

extension CGPoint {
    init(vector: vector_int2) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
}
