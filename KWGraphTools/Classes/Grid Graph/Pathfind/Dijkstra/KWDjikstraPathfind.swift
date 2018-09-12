//
//  KWDjikstraPathfind.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 09/09/18.
//

import GameplayKit

public class KWDjikstraPathfind {
    private var visited: Set<KWGridGraphNode> = Set<KWGridGraphNode>()
    private(set) var pathsGenerated: Bool = false
    
    /// Generate Weights to all nodes using Djikstra's algorithm
    ///
    /// - Parameter point: The point that all path will lead.
    public func generatePaths(forGrid grid: KWGridGraph, convergingToPoint point: vector_int2) {
        guard let startingNode = grid.node(atGridPosition: point) else { return }
        startingNode.accumulatedCost = 0
        
        self.visited.removeAll(keepingCapacity: true)
        self.updateNodeCosts(startingFromNode: startingNode)
        self.pathsGenerated = true
    }
    
    public func findPath(inGrid grid: KWGridGraph, from position: vector_int2) -> [vector_int2] {
        guard var node = grid.node(atGridPosition: position), self.visited.contains(node) else { return [] }
        guard node.accumulatedCost > 0 else { return [node.gridPosition] }
        let capacity: Int = (grid.nodes?.count ?? 0) >> 1
        let upath = UnsafeMutablePointer<vector_int2>.allocate(capacity: capacity)
        upath[0] = node.gridPosition
        var count = 1
        repeat {
            node = node.neighbourNodes.min(by: { n1, n2 in n1.accumulatedCost < n2.accumulatedCost })!
            upath[count] = node.gridPosition
            count += 1
        } while node.accumulatedCost > 0
        let path = Array(UnsafeBufferPointer(start: upath, count: count))
        upath.deallocate()
        return path
    }
    
    public func haveValidPath(inGrid grid: KWGridGraph, from position: vector_int2) -> Bool {
        guard let node = grid.node(atGridPosition: position) else { return false }
        return self.visited.contains(node)
    }
}

extension KWDjikstraPathfind {
    private func updateNodeCosts(startingFromNode node: KWGridGraphNode) {
        let frontier: PriorityQueue<KWGridGraphNode> = PriorityQueue()
        self.visited.insert(node)
        frontier.enqueue(node)
        while let currentNode: KWGridGraphNode = frontier.dequeue() {
            for connectedNode in currentNode.neighbourNodes where !self.visited.contains(connectedNode) {
                connectedNode.accumulatedCost = currentNode.accumulatedCost + currentNode.cost(to: connectedNode)
                self.visited.insert(connectedNode)
                frontier.enqueue(connectedNode)
            }
        }
    }
}
