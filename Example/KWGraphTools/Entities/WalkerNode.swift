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
        guard !gridPath.isEmpty else {
            completion()
            return
        }
        _ = self.gridPath.removeFirst()
        self.animate(completion: completion)
    }
    
    func followGKPath(gridGraph: KWGridGraph, toPoint target: GridPoint, completion: @escaping (() -> Void)) {
        guard let source = gridGraph.node(atGridPosition: vector_int2(point: self.gridPoint)),
            let target = gridGraph.node(atGridPosition: vector_int2(point: target)) else {
                completion()
                return
        }
        let path = gridGraph.findPath(from: source, to: target).compactMap {
            return $0 as? GKGridGraphNode
        }
        guard !path.isEmpty else {
            completion()
            return
        }
        self.gridPath = path.dropFirst().map{ $0.gridPosition }
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
            let destinationPoint = tileMap.centerOfTile(atColumn: Int(node.x), row: Int(node.y))
            let move = SKAction.move(to: destinationPoint, duration: 0.5)
            let update = SKAction.run {
                self.gridPoint = GridPoint(x: Int(node.x), y: Int(node.y))
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
