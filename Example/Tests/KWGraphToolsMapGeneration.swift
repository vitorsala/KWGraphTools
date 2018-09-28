//
//  KWGraphToolsMapGeneration.swift
//  KWGraphTools_Example
//
//  Created by Vitor Kawai Sala on 21/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import GameplayKit
import KWGraphTools

enum KWMapType {
    case empty
    case alternating
    case singlePath
}

final class KWGraphToolsMapGeneration {
    static func generateMap(ofSize size: CGSize, forType type: KWMapType) -> KWDijkstraGridGraph {
        let map = KWDijkstraGridGraph(fromGridStartingAt: vector_int2(x: 0, y: 0),
                              width: Int32(size.width),
                              height: Int32(size.height),
                              diagonalsAllowed: true,
                              avoidEdges: true)
        if type == .alternating {
            for row in 0..<Int(size.height) {
                for col in 0..<Int(size.width) where (row % 2 == 1 && col % 2 == 1) {
                    map.addObstacle(atGridPosition: CGPoint(x: col, y: row))
                }
            }
        } else if type == .singlePath {
            let emptyCollumn = [0, Int32(size.width - 1)]
            for row in 0..<Int(size.height) {
                for col in 0..<Int(size.width) where row % 2 == 1 {
                    let empty = (row % 4 == 3 ? 0 : 1)
                    if Int32(col) != emptyCollumn[empty] {
                        map.addObstacle(atGridPosition: CGPoint(x: col, y: row))
                    }
                }
            }
        }
        return map
    }
}
