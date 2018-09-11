//
//  KWGridGraphNode.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 28/08/18.
//

import GameplayKit

open class KWGridGraphNode: GKGridGraphNode {
    open var accumulatedCost: Float = gridGraphCostNotInitialized
    open var neighbourNodes: [KWGridGraphNode] {
        guard let nodes = self.connectedNodes as? [KWGridGraphNode] else { return [] }
        return nodes
    }
    open var leastAcumulatedCostNeighbour: KWGridGraphNode? {
        return self.neighbourNodes.min(by: {return $0.accumulatedCost < $1.accumulatedCost})
    }
}
