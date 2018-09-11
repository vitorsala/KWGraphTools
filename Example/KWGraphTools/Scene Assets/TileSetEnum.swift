//
//  TileSetEnum.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 29/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import SpriteKit

enum GroundSet: String, TileName {
    case ground_gray
    case ground_brown
    case ground_green
    case spawn_green
}

enum WallSet: String, TileName {
    case wall_orange
    case wall_gray
    case wall_brown
}

enum PropsSet: String, TileName {
    case spawn_point
    case stub_01
    case arrow_up
    case arrow_down
    case arrow_left
    case arrow_right
    case arrow_downleft
    case arrow_downright
    case arrow_upleft
    case arrow_upright
}
