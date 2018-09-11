//
//  SKTileMap+Utils.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 28/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

extension SKTileMapNode {
    func tileGroup(fromPosition point: CGPoint) -> SKTileGroup? {
        let row = self.tileRowIndex(fromPosition: point)
        let col = self.tileColumnIndex(fromPosition: point)
        return self.tileGroup(atColumn: col, row: row)
    }
}

extension SKTileSet {
    func tileGroup(named tileName: TileName) -> SKTileGroup? {
        return self.tileGroups.tileGroup(named: tileName)
    }
}

extension Array where Element == SKTileGroup {
    func tileGroup(named tileName: TileName) -> SKTileGroup? {
        return self.first { return $0.name == tileName.name }
    }
}
