//
//  KWGridGraph.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 28/08/18.
//

import GameplayKit

/// Grid Graph class for Djikstra algorithm
open class KWGridGraph: GKGridGraph<KWGridGraphNode> {
    private var pathfind: KWDijkstraPathfind = KWDijkstraPathfind()
    private var targetPoint: vector_int2 = vector_int2(x:0, y: 0)
    var avoidEdges: Bool = false
    
    public init(fromGridStartingAt position: vector_int2,
                width: Int32,
                height: Int32,
                diagonalsAllowed: Bool,
                avoidEdges: Bool,
                nodeClass: AnyClass) {
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
                let position = vector_int2(x: Int32(x), y: Int32(y))
                self.addObstacle(atGridPosition: position)
            }
        }
    }
    
    /// Generate obstacles given an another Grid Graph
    ///
    /// - Parameter gridGraph: The **KWGridGraph** containing the obstacles
    open func addObstacle(fromGridGraph gridGraph: KWGridGraph) {
        for y in 0..<self.gridHeight {
            for x in 0..<self.gridWidth {
                let position = vector_int2(x: Int32(x), y: Int32(y))
                self.addObstacle(atGridPosition: position)
            }
        }
    }
    
    /// Add an obstacle (removing graph node) at given location
    ///
    /// - Parameter point: point with coordinates of grid node that should be removed
    open func addObstacle(atGridPosition point: vector_int2) {
        guard let node = self.node(atGridPosition: point) else { return }
        self.remove([node])
        self.removeEdgeConnections(nearPoint: point)
        if self.pathfind.pathsGenerated {
            self.pathfind.generatePaths(forGrid: self, convergingToPoint: self.targetPoint)
        }
    }
    
    /// Remove an obstacle (by adding an graph node) at given location
    ///
    /// - Parameter point: point with coordinates of grid node that should be added
    open func removeObstacle(atGridPosition point: vector_int2) {
        guard self.node(atGridPosition: point) == nil else { return }
        let node = KWGridGraphNode(gridPosition: point)
        self.restoreEdgeConnections(nearPoint: point)
        self.connectToAdjacentNodes(node: node)
        if self.pathfind.pathsGenerated {
            self.pathfind.generatePaths(forGrid: self, convergingToPoint: self.targetPoint)
        }
    }
    
    /// Get GraphNode at given position
    ///
    /// - Parameter position: CGPoint with point
    /// - Returns: The node or nil if the given position don't have node
    open func node(atGridPosition position: CGPoint) -> KWGridGraphNode? {
        return self.node(atGridPosition: vector_int2(x: Int32(position.x), y: Int32(position.y)))
    }
    
    /// Get GraphNode at given position
    ///
    /// - Parameters:
    ///   - x: position in x axis
    ///   - y: position in y axis
    /// - Returns: The node or nil if the given position don't have node
    open func nodeAtGridPosition(x: Int, y: Int) -> KWGridGraphNode? {
        return self.node(atGridPosition: vector_int2(x: Int32(x), y: Int32(y)))
    }
}

extension KWGridGraph {
    /// Generate node cost for all nodes, in grid, to a given target.
    ///
    /// - Parameter point: **vector_int2** containing node that all paths should lead to.
    public func generatePaths(convergingToPoint point: vector_int2) {
        self.pathfind.generatePaths(forGrid: self, convergingToPoint: point)
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
    public func findPath(from startNode: vector_int2) -> [vector_int2] {
        let path = self.pathfind.findPath(inGrid: self, from: startNode)
        return path
    }
    
    /// Return if the given node have an valid path to target.
    ///
    /// This method will return **false** if `generatePaths(convergingToPoint:)` was not called prior this method.
    /// - Parameter point: **vector_int2** origin point where path will start.
    /// - Returns: **Bool** indicating if the given point have a valid path to target.
    public func haveValidPath(from point: vector_int2) -> Bool {
        return self.pathfind.haveValidPath(inGrid: self, from: point)
    }
}

extension KWGridGraph {
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
