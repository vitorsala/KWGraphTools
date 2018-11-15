//
//  KWDijkstraGridGraph.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 28/08/18.
//

import GameplayKit

/// Grid Graph class for Djikstra algorithm
open class KWDijkstraGridGraph: GKGridGraph<GKGridGraphNode> {
    private var visited: Set<GKGridGraphNode> = Set<GKGridGraphNode>()
    private var costs: [GKGridGraphNode: Float] = [:]
    private var targetPoint: CGPoint = CGPoint.zero
    private(set) var pathsGenerated: Bool = false
    var avoidEdges: Bool = false
    
    public init(fromGridStartingAt position: vector_int2,
                width: Int32,
                height: Int32,
                diagonalsAllowed: Bool,
                avoidEdges: Bool,
                nodeClass: AnyClass = GKGridGraphNode.self) {
        self.avoidEdges = avoidEdges
        super.init(fromGridStartingAt: position, width: width, height: height, diagonalsAllowed: diagonalsAllowed, nodeClass: nodeClass)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Remove obstacles given an walkable tile map
    ///
    /// - Parameter tileMap: The tile map containing walkable tiles
    open func addWalkablePoints(fromTileMap tileMap: SKTileMapNode) {
        for y in 0..<self.gridHeight {
            for x in 0..<self.gridWidth where tileMap.haveTile(atColumn: x, row: y) {
                let position = vector_int2(x: Int32(x), y: Int32(y))
                self.removeObstacle(atGridPosition: position)
            }
        }
    }
    
    /// Generate obstacles given an obstacle tile map.
    ///
    /// - Parameter tileMap: The tile map containing obstacles.
    open func addObstacle(fromTileMap tileMap: SKTileMapNode) {
        for y in 0..<self.gridHeight {
            for x in 0..<self.gridWidth where tileMap.haveTile(atColumn: x, row: y) {
                let position = CGPoint(x: x, y: y)
                self.addObstacle(atGridPosition: position)
            }
        }
    }
    
    /// Generate obstacles given an another Grid Graph
    ///
    /// - Parameter gridGraph: The **KWGridGraph** containing the obstacles
    open func addObstacle(fromGridGraph gridGraph: KWDijkstraGridGraph) {
        for y in 0..<self.gridHeight {
            for x in 0..<self.gridWidth {
                let position = CGPoint(x: x, y: y)
                self.addObstacle(atGridPosition: position)
            }
        }
    }
    
    /// Add an obstacle (removing graph node) at given location
    ///
    /// - Parameter point: point with coordinates of grid node that should be removed
    open func addObstacle(atGridPosition point: CGPoint) {
        guard let node = self.node(atGridPosition: point) else { return }
        let vectorPoint = vector_int2(point: point)
        self.remove([node])
        self.removeEdgeConnections(nearPoint: vectorPoint)
        if self.pathsGenerated {
            self.generatePaths(convergingToPoint: self.targetPoint)
        }
    }
    
    /// Remove an obstacle (by adding an graph node) at given location
    ///
    /// - Parameter point: point with coordinates of grid node that should be added
    open func removeObstacle(atGridPosition point: vector_int2) {
        guard self.node(atGridPosition: point) == nil else { return }
        let node = GKGridGraphNode(gridPosition: point)
        self.restoreEdgeConnections(nearPoint: point)
        self.connectToAdjacentNodes(node: node)
        if self.pathsGenerated {
            self.generatePaths(convergingToPoint: self.targetPoint)
        }
    }
    
    /// Get GraphNode at given position
    ///
    /// - Parameter position: CGPoint with point
    /// - Returns: The node or nil if the given position don't have node
    open func node(atGridPosition position: CGPoint) -> GKGridGraphNode? {
        return self.node(atGridPosition: vector_int2(x: Int32(position.x), y: Int32(position.y)))
    }
    
    /// Get GraphNode at given position
    ///
    /// - Parameters:
    ///   - x: position in x axis
    ///   - y: position in y axis
    /// - Returns: The node or nil if the given position don't have node
    open func nodeAtGridPosition(x: Int, y: Int) -> GKGridGraphNode? {
        return self.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y)))
    }
}

extension KWDijkstraGridGraph {
    /// Generate node cost for all nodes, in grid, to a given target.
    ///
    /// - Parameter point: **vector_int2** containing node that all paths should lead to.
    public func generatePaths(convergingToPoint point: CGPoint) {
        guard let startingNode = self.node(atGridPosition: point) else { return }
        self.costs[startingNode] = 0
        
        self.visited.removeAll(keepingCapacity: true)
        self.updateNodeCosts(startingFromNode: startingNode)
        self.pathsGenerated = true
        self.targetPoint = point
    }
    
    /// Calculate an path from given point to converging point.
    ///
    /// This method works only if the graph was previously generated with
    /// ```
    /// generatePaths(convergingToPoint: vector_int2)
    /// ```
    /// - Parameter startNode: **vector_int2** the starting point where path will start from.
    /// - Returns: **[vector_int2]** containing every grid point the shortest path
    public func findPath(from startNode: CGPoint) -> [GKGridGraphNode] {
        guard var node = self.node(atGridPosition: startNode), self.visited.contains(node) else { return [] }
        guard (self.costs[node] ?? 0) > 0 else { return [node] }
        var path: [GKGridGraphNode] = [node]
        repeat {
            for case let connectedNode as GKGridGraphNode in node.connectedNodes {
                if self.costs[connectedNode]! < self.costs[node]! {
                    node = connectedNode
                }
            }
            path.append(node)
        } while self.costs[node]! > 0
        return path
    }
    
    /// Return if the given node have an valid path to target.
    ///
    /// This method will return **false** if `generatePaths(convergingToPoint:)` was not called prior this method.
    /// - Parameter point: **vector_int2** origin point where path will start.
    /// - Returns: **Bool** indicating if the given point have a valid path to target.
    public func haveValidPath(from point: CGPoint) -> Bool {
        guard let node = self.node(atGridPosition: point) else { return false }
        return self.visited.contains(node)
    }
    
    private func updateNodeCosts(startingFromNode node: GKGridGraphNode) {
        let frontier: PriorityQueue<GKGridGraphNode> = PriorityQueue()
        self.visited.insert(node)
        frontier.enqueue(node, priority: 0)
        while let currentNode: GKGridGraphNode = frontier.dequeue() {
            for case let connectedNode as GKGridGraphNode in currentNode.connectedNodes where !self.visited.contains(connectedNode) {
                let currentCost = self.costs[currentNode]! + 1
                self.costs[connectedNode] = currentCost
                self.visited.insert(connectedNode)
                frontier.enqueue(connectedNode, priority: currentCost)
            }
        }
    }
}

extension KWDijkstraGridGraph {
    internal func removeEdgeConnections(nearPoint point: vector_int2) {
        guard !self.diagonalsAllowed, self.avoidEdges else { return }
        for x in [point.x - 1, point.x + 1] {
            if let n1 = self.node(atGridPosition: vector_int2(x: x, y: point.y)) {
                for y in [point.y - 1, point.y + 1] {
                    if let n2 = self.node(atGridPosition: vector_int2(x: point.x, y: y)) {
                        n1.removeConnections(to: [n2], bidirectional: true)
                    }
                }
            }
        }
    }
    
    internal func restoreEdgeConnections(nearPoint point: vector_int2) {
        guard !diagonalsAllowed, self.avoidEdges else { return }
        for x in [point.x - 1, point.x + 1] {
            if let n1 = self.node(atGridPosition: vector_int2(x: x, y: point.y)) {
                for y in [point.y - 1, point.y + 1] {
                    if let n2 = self.node(atGridPosition: vector_int2(x: point.x, y: y)) {
                        n1.addConnections(to: [n2], bidirectional: true)
                    }
                }
            }
        }
    }
}
