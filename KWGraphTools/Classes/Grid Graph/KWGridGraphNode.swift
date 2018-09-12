//
//  KWGridGraphNode.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 28/08/18.
//

import GameplayKit

open class KWGridGraphNode: GKGridGraphNode {
    open var accumulatedCost: Float = Float.greatestFiniteMagnitude
    open var neighbourNodes: [KWGridGraphNode] {
        guard let nodes = self.connectedNodes as? [KWGridGraphNode] else { return [] }
        return nodes
    }
    open var leastAcumulatedCostNeighbour: KWGridGraphNode? {
        return self.neighbourNodes.min(by: {return $0.accumulatedCost < $1.accumulatedCost})
    }
}

extension KWGridGraphNode: Comparable {
    public static func < (lhs: KWGridGraphNode, rhs: KWGridGraphNode) -> Bool {
        return lhs.accumulatedCost < rhs.accumulatedCost
    }
    
    public static func > (lhs: KWGridGraphNode, rhs: KWGridGraphNode) -> Bool {
        return lhs.accumulatedCost > rhs.accumulatedCost
    }
    
    public static func == (lhs: KWGridGraphNode, rhs: KWGridGraphNode) -> Bool {
        return lhs.accumulatedCost == rhs.accumulatedCost
    }
}
