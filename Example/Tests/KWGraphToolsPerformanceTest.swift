//
//  KWGraphToolsPerformanceTest.swift
//  KWGraphTools_Tests
//
//  Created by Vitor Kawai Sala on 21/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Foundation
import GameplayKit
import KWGraphTools

class KWGraphToolsPerformanceTest: XCTestCase {
    var numberOfAgents: Int = 10000
    var mapSize: Int = 27
    
    func testGKPerformanceForEmptyMap() {
        let graph = KWGraphToolsMapGeneration.generateMap(ofSize: CGSize(width: mapSize, height: mapSize), forType: .empty)
        let origin = graph.nodeAtGridPosition(x: 0, y: 0)!
        let destination = graph.nodeAtGridPosition(x: graph.gridWidth - 1, y: graph.gridHeight - 1)!
        // GKPathfinding
        self.measure {
            for _ in 0..<numberOfAgents {
                graph.findPath(from: origin, to: destination)
            }
        }
    }
    
    func testKWPerformanceForEmptyMap() {
        let graph = KWGraphToolsMapGeneration.generateMap(ofSize: CGSize(width: mapSize, height: mapSize), forType: .empty)
        // KWGraphTools
        self.measure {
            graph.generatePaths(convergingToPoint: CGPoint(x: (graph.gridWidth - 1), y: (graph.gridHeight - 1)))
            for _ in 0..<numberOfAgents {
                _ = graph.findPath(from: CGPoint(x: 0, y: 0))
            }
        }
    }
    
    func testGKPerformanceForAlternatingObstacles() {
        let graph = KWGraphToolsMapGeneration.generateMap(ofSize: CGSize(width: mapSize, height: mapSize), forType: .alternating)
        let origin = graph.nodeAtGridPosition(x: 0, y: 0)!
        let destination = graph.nodeAtGridPosition(x: graph.gridWidth - 1, y: graph.gridHeight - 1)!
        // GKPathfinding
        self.measure {
            for _ in 0..<numberOfAgents {
                graph.findPath(from: origin, to: destination)
            }
        }
    }
    
    func testKWPerformanceForAlternatingObstacles() {
        let graph = KWGraphToolsMapGeneration.generateMap(ofSize: CGSize(width: mapSize, height: mapSize), forType: .alternating)
        // KWGraphTools
        self.measure {
            graph.generatePaths(convergingToPoint: CGPoint(x: (graph.gridWidth - 1), y: (graph.gridHeight - 1)))
            for _ in 0..<numberOfAgents {
                _ = graph.findPath(from: CGPoint(x: 0, y: 0))
            }
        }
    }
    
    func testGKPerformanceForSinglePath() {
        let graph = KWGraphToolsMapGeneration.generateMap(ofSize: CGSize(width: mapSize, height: mapSize), forType: .singlePath)
        let origin = graph.nodeAtGridPosition(x: 0, y: 0)!
        let destination = graph.nodeAtGridPosition(x: 0, y: graph.gridHeight - 1)!
        // GKPathfinding
        self.measure {
            for _ in 0..<numberOfAgents {
                graph.findPath(from: origin, to: destination)
            }
        }
    }
    
    func testKWPerformanceForSinglePath() {
        let graph = KWGraphToolsMapGeneration.generateMap(ofSize: CGSize(width: mapSize, height: mapSize), forType: .singlePath)
        // KWGraphTools
        self.measure {
            graph.generatePaths(convergingToPoint: CGPoint(x: 0, y: (graph.gridHeight - 1)))
            for _ in 0..<numberOfAgents {
                _ = graph.findPath(from: CGPoint(x: 0, y: 0))
            }
        }
    }
}
