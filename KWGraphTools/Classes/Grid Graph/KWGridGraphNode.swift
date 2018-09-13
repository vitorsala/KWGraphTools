//
//  KWGridGraphNode.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 28/08/18.
//

import GameplayKit

/// The Grid Graph Node for Djikstra Algorithm
open class KWGridGraphNode: GKGridGraphNode {
    /// The node cost relative to target.
    open var accumulatedCost: Float = Float.greatestFiniteMagnitude
    /// Neighbour nodes relative to this node.
    open var neighbourNodes: [KWGridGraphNode] {
        guard let nodes = self.connectedNodes as? [KWGridGraphNode] else { return [] }
        return nodes
    }
    /// The neighbour with the least cost.
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
