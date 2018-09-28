//
//  SKTileMapNodeExtension.swift
//  KWGraphTools
//
//  Created by Vitor Kawai Sala on 28/08/18.
//

import SpriteKit
import GameplayKit

public extension SKTileMapNode {
    /// Generate a Grid Graph to this tile map.
    ///
    /// - Parameter diagonalAllowed: **Bool** indicating if this tile map accepts diagonal movements.
    /// - Returns: An **KWGridGraph** containing the graph
    public func generateGridGraph(diagonalAllowed: Bool, avoidEdges: Bool = true) -> KWDijkstraGridGraph {
        let graph: KWDijkstraGridGraph = KWDijkstraGridGraph(
            fromGridStartingAt: vector_int2(x: 0, y: 0),
            width: Int32(self.numberOfColumns),
            height: Int32(self.numberOfRows),
            diagonalsAllowed: diagonalAllowed,
            avoidEdges: avoidEdges
        )
        
        graph.avoidEdges = avoidEdges
        
        // Seek for every non filled tile, and remove the graph node correspoding to the tile.
        for row in 0..<self.numberOfRows {
            for column in 0..<self.numberOfColumns where !self.haveTile(atColumn: column, row: row) {
                if let node: GKGridGraphNode = graph.node(atGridPosition: vector_int2(x: Int32(column), y: Int32(row))) {
                    graph.remove([node])
                }
            }
        }
        return graph
    }
    
    /// Verify if there is a tile at a grid position
    ///
    /// - Parameters:
    ///   - column: The column to be verified
    ///   - row: The row to be verified
    /// - Returns: **Bool** indicating if there is an tile at given position.
    public func haveTile(atColumn column: Int, row: Int) -> Bool {
        return self.tileGroup(atColumn: column, row: row) != nil
    }
}
