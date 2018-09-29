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
    var gridPath: [GKGridGraphNode] = []
    
    func followPath(gridGraph: KWDijkstraGridGraph, completion: @escaping (() -> Void)) {
        self.gridPath = gridGraph.findPath(from: self.gridPoint.cgPoint)
        _ = self.gridPath.removeFirst()
        guard !self.gridPath.isEmpty else {
            completion()
            return
        }
        self.animate(completion: completion)
    }
    
    func followGKPath(gridGraph: KWDijkstraGridGraph, toPoint target: GridPoint, completion: @escaping (() -> Void)) {
        guard let source = gridGraph.node(atGridPosition: vector_int2(point: self.gridPoint)),
            let target = gridGraph.node(atGridPosition: vector_int2(point: target)) else {
                completion()
                return
        }
        self.gridPath = gridGraph.findPath(from: source, to: target).compactMap {
            return $0 as? GKGridGraphNode
        }
        _ = self.gridPath.removeFirst()
        guard !self.gridPath.isEmpty else {
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
        var actions: [SKAction] = []
        for node in self.gridPath {
            let destinationPoint = tileMap.centerOfTile(atColumn: Int(node.gridPosition.x), row: Int(node.gridPosition.y))
            let move = SKAction.move(to: destinationPoint, duration: 0.5)
            let update = SKAction.run {
                self.gridPoint = GridPoint(x: Int(node.gridPosition.x), y: Int(node.gridPosition.y))
            }
            actions.append(move)
            actions.append(update)
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
