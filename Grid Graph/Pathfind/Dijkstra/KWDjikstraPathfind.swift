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
        self.updateNodeCosts(startingFromNode: startingNode, visitedSet: &self.visited)
        self.pathsGenerated = true
    }
    
    public func findPath(inGrid grid: KWGridGraph, from position: vector_int2) -> [vector_int2] {
        guard var node = grid.node(atGridPosition: position), node.accumulatedCost < gridGraphCostNotInitialized else { return [] }
        guard node.accumulatedCost > 0 else { return [node.gridPosition] }
        let capacity: Int = (grid.nodes?.count ?? 0) >> 1
        let upath = UnsafeMutablePointer<vector_int2>.allocate(capacity: capacity)
        var count = 0
        repeat {
            upath[count] = node.gridPosition
            count += 1
            node = node.neighbourNodes.min(by: { n1, n2 in n1.accumulatedCost < n2.accumulatedCost })!
        } while node.accumulatedCost > 0
        let path = Array(UnsafeBufferPointer(start: upath, count: count))
        upath.deallocate()
        return path
    }
    
    public func haveValidPath(inGrid grid: KWGridGraph, from position: vector_int2) -> Bool {
        guard let node = grid.node(atGridPosition: position) else { return false }
        return self.visited.contains(node)
    }
    
    internal func updatePaths(forGrid grid: KWGridGraph, afterInsertingNode startingNode: KWGridGraphNode) {
        var localVisitedSet = Set<KWGridGraphNode>(minimumCapacity: self.visited.capacity)
        guard let leatestCostNode = startingNode.leastAcumulatedCostNeighbour else { return } // If this is false, means that this node does not cotains an neighbour (lonely node)
        startingNode.accumulatedCost = leatestCostNode.accumulatedCost + 1
        self.updateNodeCosts(startingFromNode: startingNode, visitedSet: &localVisitedSet) { (current, neighbour) -> Bool in
            return neighbour.accumulatedCost > current.accumulatedCost
        }
        self.visited.insert(startingNode)
    }
}

extension KWDjikstraPathfind {
    private func updateNodeCosts(startingFromNode node: KWGridGraphNode,
                                 visitedSet set: inout Set<KWGridGraphNode>,
                                 additionalCondition cond: ((KWGridGraphNode, KWGridGraphNode) -> Bool)? = nil) {
        
        let frontier: PriorityQueue<KWGridGraphNode> = PriorityQueue()
        set.insert(node)
        frontier.enqueue(element: node, withPriority: node.accumulatedCost)
        self.updateNodeCosts(startingWithFrontier: frontier, visitedSet: &set, additionalCondition: cond)
    }
    
    private func updateNodeCosts(startingWithFrontier frontier: PriorityQueue<KWGridGraphNode>,
                                 visitedSet set: inout Set<KWGridGraphNode>,
                                 additionalCondition cond: ((KWGridGraphNode, KWGridGraphNode) -> Bool)? = nil) {
        
        while let currentNode: KWGridGraphNode = frontier.dequeue() {
            for connectedNode in currentNode.neighbourNodes where !set.contains(connectedNode) && (cond?(currentNode, connectedNode) ?? true) {
                connectedNode.accumulatedCost = currentNode.accumulatedCost + currentNode.cost(to: connectedNode)
                set.insert(connectedNode)
                frontier.enqueue(element: connectedNode, withPriority: connectedNode.accumulatedCost)
            }
        }
    }
    
    internal func updatePath(forGrid grid: KWGridGraph, removingNode nodeToBeRemoved: KWGridGraphNode) {
        let frontier: PriorityQueue<KWGridGraphNode> = self.frontierUpdatingNodes(startingFrom: nodeToBeRemoved)
        grid.remove([nodeToBeRemoved])
        self.updateNodeCosts(startingWithFrontier: frontier, visitedSet: &self.visited)
    }
    
    private func frontierUpdatingNodes(startingFrom node: KWGridGraphNode) -> PriorityQueue<KWGridGraphNode> {
        let frontier: PriorityQueue<KWGridGraphNode> = PriorityQueue()
        var clearedNodes: [KWGridGraphNode] = []
        let startingNeighbours = node.neighbourNodes.filter { $0.accumulatedCost > node.accumulatedCost }
        
        startingNeighbours.forEach {
            self.visited.remove($0)
            clearedNodes.append($0)
        }
        self.visited.remove(node)
        while !clearedNodes.isEmpty {
            let current = clearedNodes.removeFirst()
            for neighbour in current.neighbourNodes where self.visited.contains(neighbour) {
                self.visited.remove(neighbour)
                if neighbour.accumulatedCost > current.accumulatedCost {
                    clearedNodes.append(neighbour)
                } else if let leastestCostNode = neighbour.leastAcumulatedCostNeighbour {
                    neighbour.accumulatedCost = leastestCostNode.accumulatedCost + leastestCostNode.cost(to: neighbour)
                    frontier.enqueue(element: neighbour, withPriority: neighbour.accumulatedCost)
                }
            }
        }
        return frontier
    }
}
